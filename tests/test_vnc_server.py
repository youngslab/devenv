import importlib.machinery
import importlib.util
import os
from pathlib import Path
import subprocess
import socket
import tempfile
import sys
import time
from unittest import mock
import unittest

ROOT = Path(__file__).resolve().parents[1]
loader = importlib.machinery.SourceFileLoader('vnc_server', str(ROOT / 'scripts/vnc-server'))
spec = importlib.util.spec_from_loader(loader.name, loader)
vnc = importlib.util.module_from_spec(spec)
loader.exec_module(vnc)


class OwnershipTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.manager = vnc.Manager(Path(self.tmp.name) / 'state', budget=1)
        self.manager.prepare()

    def tearDown(self):
        self.tmp.cleanup()

    def test_symlink_rejected(self):
        link = Path(self.tmp.name) / 'link'
        link.symlink_to(self.manager.directory)
        with self.assertRaises(vnc.ServiceError):
            vnc.Manager(link).prepare()

    def test_legacy_pid_never_adopted_or_killed(self):
        self.manager.path('xvfb').write_text(str(os.getpid()))
        with self.assertRaises(vnc.ServiceError):
            self.manager.record('xvfb')
        self.assertTrue(self.manager.path('xvfb').exists())

    def test_reused_pid_not_signalled(self):
        identity = vnc.identity(os.getpid())
        identity['start'] = 'wrong'
        self.manager.save('xvfb', identity)
        self.assertIsNone(self.manager.record('xvfb'))
        self.assertTrue(self.manager.path('xvfb').exists())

    def test_real_child_identity_and_stop(self):
        child = subprocess.Popen(['sleep', '30'], start_new_session=True)
        try:
            self.manager.save('fluxbox', vnc.identity(child.pid))
            self.manager.stop_one('fluxbox')
            child.wait(timeout=2)
            self.assertFalse(self.manager.path('fluxbox').exists())
        finally:
            if child.poll() is None:
                child.kill()
                child.wait()

    def test_only_owned_dead_display_socket_is_cleaned(self):
        sockpath = Path(self.tmp.name) / 'X99'
        lockpath = Path(self.tmp.name) / 'X99-lock'
        sock = socket.socket(socket.AF_UNIX)
        sock.bind(str(sockpath))
        sock.close()  # stale Unix socket, not listening
        dead_pid = 2147483647
        lockpath.write_text(str(dead_pid))
        record = {'pid': dead_pid, 'start': 'old', 'exe': '/usr/bin/Xvfb',
                  'args': vnc.COMMANDS['xvfb'], 'uid': os.getuid()}
        with mock.patch.object(vnc, 'XSOCKET', sockpath), mock.patch.object(vnc, 'XLOCK', lockpath):
            self.manager.cleanup_stale_display()
            self.assertTrue(sockpath.exists())  # unknown display never removed
            self.manager.save('xvfb', record)
            self.manager.cleanup_stale_display()
            self.assertFalse(sockpath.exists())
            self.assertFalse(lockpath.exists())

    def test_live_display_socket_is_never_cleaned(self):
        sockpath = Path(self.tmp.name) / 'X99'
        lockpath = Path(self.tmp.name) / 'X99-lock'
        dead_pid = 2147483647
        lockpath.write_text(str(dead_pid))
        self.manager.save('xvfb', {'pid': dead_pid, 'start': 'old', 'exe': '/usr/bin/Xvfb',
                  'args': vnc.COMMANDS['xvfb'], 'uid': os.getuid()})
        with socket.socket(socket.AF_UNIX) as sock:
            sock.bind(str(sockpath))
            sock.listen(1)
            with mock.patch.object(vnc, 'XSOCKET', sockpath), mock.patch.object(vnc, 'XLOCK', lockpath):
                self.manager.cleanup_stale_display()
            self.assertTrue(sockpath.exists())
            self.assertTrue(lockpath.exists())

    def test_loopback_arguments(self):
        self.assertIn('-nolisten', vnc.COMMANDS['xvfb'])
        self.assertIn('127.0.0.1', vnc.COMMANDS['vnc'])
        self.assertIn('-noipv6', vnc.COMMANDS['vnc'])
        self.assertEqual(vnc.COMMANDS['vnc'][vnc.COMMANDS['vnc'].index('-rfbportv6') + 1], '-1')
        self.assertIn('127.0.0.1:7900', vnc.COMMANDS['novnc'])
        self.assertIn('127.0.0.1:5900', vnc.COMMANDS['novnc'])

    def test_protocol_probes_recompute_remaining_timeout(self):
        for service, budgets, reply, expected_timeouts in (
                ('vnc', [1.5, .4], b'RFB 003.008\n', [.4]),
                ('novnc', [1.5, .8, .2], b'HTTP/1.0 200 OK', [.8, .2])):
            with self.subTest(service=service):
                record = {'pid': 123, 'args': vnc.COMMANDS[service]}
                connection = mock.MagicMock()
                connection.__enter__.return_value = connection
                connection.recv.return_value = reply
                with mock.patch.object(vnc, 'identity', return_value=record), \
                     mock.patch.object(vnc, 'listening', return_value=[('tcp', '0100007F')]), \
                     mock.patch.object(self.manager, 'remaining', side_effect=budgets), \
                     mock.patch.object(vnc.socket, 'create_connection', return_value=connection) as connect:
                    self.assertTrue(self.manager.ready(service, record))
                self.assertEqual(connect.call_args.kwargs['timeout'], 1.5)
                self.assertEqual(connection.settimeout.call_args_list,
                                 [mock.call(value) for value in expected_timeouts])

    def test_deadline(self):
        self.manager.deadline = 0
        with self.assertRaises(vnc.ServiceError):
            self.manager.remaining()


class LifecycleTests(unittest.TestCase):
    """Real owned processes, isolated state; never uses actual X sockets/ports."""
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.manager = vnc.Manager(Path(self.tmp.name) / 'state', budget=3)
        self.manager.prepare()
        self.commands = mock.patch.dict(vnc.COMMANDS, {
            service: [sys.executable, '-c', 'import time; time.sleep(30)', service]
            for service in vnc.SERVICES})
        self.commands.start()
        self.workdirs = mock.patch.dict(vnc.WORKDIRS, {}, clear=True)
        self.workdirs.start()
        self.conflict = mock.patch.object(vnc.Manager, 'conflict')
        self.conflict.start()
        self.ready = mock.patch.object(vnc.Manager, 'ready',
            lambda manager, service, record: vnc.identity(record['pid']) == record)
        self.ready.start()

    def tearDown(self):
        self.manager.stop()
        self.ready.stop()
        self.conflict.stop()
        self.commands.stop()
        self.workdirs.stop()
        self.tmp.cleanup()

    def test_idempotence_and_partial_repair(self):
        self.manager.ensure()
        before = {s: self.manager.record(s)['pid'] for s in vnc.SERVICES}
        self.manager.ensure()
        self.assertEqual(before, {s: self.manager.record(s)['pid'] for s in vnc.SERVICES})
        self.manager.stop_one('novnc')
        self.manager.ensure()
        after = {s: self.manager.record(s)['pid'] for s in vnc.SERVICES}
        self.assertEqual(before['xvfb'], after['xvfb'])
        self.assertNotEqual(before['novnc'], after['novnc'])

    def test_daemons_do_not_inherit_lock(self):
        fd = self.manager.lock()
        self.manager.ensure()
        os.close(fd)
        other = vnc.Manager(self.manager.directory, budget=.3)
        fd = other.lock()
        os.close(fd)

    def test_failed_readiness_cleans_new_child(self):
        self.manager.deadline = time.monotonic() + .15
        with mock.patch.object(vnc.Manager, 'ready', return_value=False):
            with self.assertRaises(vnc.ServiceError):
                self.manager.launch('xvfb')
        self.assertIsNotNone(self.manager.children['xvfb'].poll())
        self.assertFalse(self.manager.path('xvfb').exists())

    def test_failed_record_write_cleans_child(self):
        with mock.patch.object(vnc.Manager, 'save', side_effect=OSError('disk full')):
            with self.assertRaises(vnc.ServiceError):
                self.manager.launch('xvfb')
        self.assertIsNotNone(self.manager.children['xvfb'].poll())

    def test_lock_contention_bounded(self):
        fd = self.manager.lock()
        try:
            other = vnc.Manager(self.manager.directory, budget=.1)
            started = time.monotonic()
            with self.assertRaises(vnc.ServiceError):
                other.lock()
            self.assertLess(time.monotonic() - started, .5)
        finally:
            os.close(fd)


if __name__ == '__main__':
    unittest.main()
