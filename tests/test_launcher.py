"""Launcher regression tests: Docker is always stubbed; never touches real containers."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOCKER = '''#!/usr/bin/env python3
import json, os, sys
args = sys.argv[1:]
with open(os.environ['DOCKER_LOG'], 'a') as log:
    log.write(json.dumps(args) + '\\n')
if args[0] == 'ps':
    if os.environ['BRANCH'] == 'running' or (os.environ['BRANCH'] == 'stopped' and '-a' in args):
        print('devenv')
if args[0] == 'exec' and '-it' in args:
    sys.exit(23)
'''


class LauncherTests(unittest.TestCase):
    def test_all_routes_keep_tmux_and_display(self):
        for branch in ('running', 'stopped', 'new'):
            with self.subTest(branch=branch), tempfile.TemporaryDirectory() as tmp:
                home = Path(tmp)
                binary = home / 'docker'
                binary.write_text(DOCKER)
                binary.chmod(0o755)
                log = home / 'calls'
                result = subprocess.run(['bash', str(ROOT / 'scripts/devenv'), 'printf', '%s', 'space argument'],
                    env={**os.environ, 'HOME': tmp, 'PATH': tmp + ':' + os.environ['PATH'],
                         'DOCKER_LOG': str(log), 'BRANCH': branch, 'DISPLAY': 'host:10'},
                    capture_output=True, text=True)
                self.assertEqual(result.returncode, 23, result.stderr)
                calls = [json.loads(line) for line in log.read_text().splitlines()]
                attachments = [call for call in calls if call[0] == 'exec' and '-it' in call]
                self.assertEqual(len(attachments), 1)
                self.assertIn('DISPLAY=:99', attachments[0])
                self.assertIn('--user', attachments[0])
                self.assertIn('tmux', attachments[0])
                self.assertIn('space\\ argument', attachments[0][-1])
                self.assertFalse(any(call[0] in ('rm', 'build') for call in calls))
                ensures = [call for call in calls if call[0] == 'exec' and '-it' not in call]
                self.assertEqual(len(ensures), 1)
                self.assertIn('safe-ensure-v1', ensures[0][-1])
                self.assertNotIn('vnc-server start', ensures[0][-1])
                if branch == 'new':
                    preparation = next(call for call in calls if '--rm' in call)
                    self.assertIn('DEVENV_VNC_AUTOSTART=0', preparation)
                    self.assertEqual(preparation[preparation.index('--entrypoint') + 1], 'chown')
                    launch = next(call for call in calls if call[0] == 'run' and '-d' in call)
                    self.assertIn('DISPLAY=:99', launch)

    def test_interactive_attach_uses_main_with_display(self):
        for arguments in ([], ['zsh']):
            with self.subTest(arguments=arguments), tempfile.TemporaryDirectory() as tmp:
                binary = Path(tmp) / 'docker'
                binary.write_text(DOCKER)
                binary.chmod(0o755)
                log = Path(tmp) / 'calls'
                result = subprocess.run(['bash', str(ROOT / 'scripts/devenv'), *arguments],
                    env={**os.environ, 'HOME': tmp, 'PATH': tmp + ':' + os.environ['PATH'],
                         'DOCKER_LOG': str(log), 'BRANCH': 'running'}, capture_output=True)
                self.assertEqual(result.returncode, 23)
                calls = [json.loads(line) for line in log.read_text().splitlines()]
                attach = next(call for call in calls if call[0] == 'exec' and '-it' in call)
                self.assertEqual(attach[-7:],
                    ['tmux', 'new-session', '-e', 'DISPLAY=:99', '-A', '-s', 'main'])

    def test_attach_guard_optout_legacy_and_failure(self):
        source = (ROOT / 'scripts/devenv').read_text()
        guard = source.split('"$CONTAINER_NAME" sh -c \'', 1)[1].split("\n  '", 1)[0]
        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / 'vnc-server'
            binary.write_text('#!/bin/sh\necho "$*" >> "$CALLS"\n'
                              '[ "$1" = capabilities ] && { echo "$CAPABILITY"; exit 0; }\n'
                              'exit 7\n')
            binary.chmod(0o755)
            calls = Path(tmp) / 'calls'
            env = {**os.environ, 'PATH': tmp + ':' + os.environ['PATH'], 'CALLS': str(calls)}
            for optout, capability, expected_calls, code in [
                    ('0', 'safe-ensure-v1', [], 0),
                    ('1', 'legacy', ['capabilities'], 0),
                    ('1', 'safe-ensure-v1', ['capabilities', 'ensure'], 7)]:
                calls.unlink(missing_ok=True)
                result = subprocess.run(['sh', '-c', guard], env={**env,
                    'DEVENV_VNC_AUTOSTART': optout, 'CAPABILITY': capability}, capture_output=True)
                self.assertEqual(result.returncode, code)
                self.assertEqual(calls.read_text().splitlines() if calls.exists() else [], expected_calls)

    def test_entrypoint_order_and_image_defaults(self):
        script = (ROOT / 'scripts/entrypoint.sh').read_text()
        self.assertLess(script.index('vnc-server ensure'), script.index('npm update'))
        self.assertIn('${DEVENV_VNC_AUTOSTART:-1}', script)
        dockerfile = (ROOT / 'Dockerfile').read_text()
        self.assertIn('ENV DISPLAY=:99', dockerfile)
        self.assertIn('ENV DEVENV_VNC_AUTOSTART=1', dockerfile)


if __name__ == '__main__':
    unittest.main()
