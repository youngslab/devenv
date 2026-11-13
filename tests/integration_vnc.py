#!/usr/bin/env python3
"""Opt-in real-service checks using an existing devenv image; no live mounts/ports."""
import argparse
import concurrent.futures
import json
from pathlib import Path
import subprocess
import tempfile
import time
import uuid

ROOT = Path(__file__).resolve().parents[1]


def run(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, capture_output=True,
                          timeout=kwargs.pop('timeout', 45), **kwargs).stdout.strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--base-image', default='devenv:latest')
    args = parser.parse_args()
    name = 'devenv-vnc-test-' + uuid.uuid4().hex[:10]
    image = name + ':local'

    def execute(*command, **kwargs):
        return run('docker', 'exec', name, *command, **kwargs)

    def ready():
        deadline = time.monotonic() + 20
        while time.monotonic() < deadline:
            try:
                output = execute('vnc-server', 'status')
                assert output.count(': ready') == 4, output
                return
            except (subprocess.CalledProcessError, AssertionError):
                time.sleep(.3)
        logs = subprocess.run(['docker', 'logs', name], capture_output=True, text=True)
        raise AssertionError(logs.stdout + logs.stderr)

    def record(service):
        return json.loads(execute('cat', '/tmp/vnc/' + service + '.pid'))

    try:
        with tempfile.TemporaryDirectory() as directory:
            dockerfile = Path(directory) / 'Dockerfile'
            dockerfile.write_text(f'''FROM {args.base_image}
COPY scripts/vnc-server /usr/local/bin/vnc-server
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
ENV DISPLAY=:99 DEVENV_VNC_AUTOSTART=1
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
''')
            run('docker', 'build', '-q', '-f', str(dockerfile), '-t', image,
                str(ROOT), timeout=180)
        run('docker', 'run', '-d', '--name', name, '--network', 'none', image)
        ready()
        assert execute('printenv', 'DISPLAY') == ':99'
        print('PASS fresh entrypoint startup and Docker exec DISPLAY', flush=True)
        original = {s: record(s) for s in ('xvfb', 'fluxbox', 'vnc', 'novnc')}
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
            list(pool.map(lambda _: execute('vnc-server', 'ensure'), range(4)))
        assert original == {s: record(s) for s in original}
        print('PASS concurrent ensure preserves all identities and releases lock', flush=True)
        execute('python3', '-c', '''import base64,subprocess
image=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a9x8AAAAASUVORK5CYII=')
subprocess.run(['xclip','-selection','clipboard','-t','image/png','-i'],input=image,check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
''')
        execute('kill', '-TERM', str(original['novnc']['pid']))
        time.sleep(.3)
        execute('vnc-server', 'ensure')
        assert record('xvfb') == original['xvfb']
        assert record('novnc') != original['novnc']
        assert 'image/png' in execute('xclip', '-selection', 'clipboard', '-o', '-t', 'TARGETS')
        print('PASS partial recovery preserves X server and remote image clipboard', flush=True)
        execute('python3', '-c', '''from pathlib import Path
found=[]
for table in ('tcp','tcp6'):
 for line in Path('/proc/net',table).read_text().splitlines()[1:]:
  fields=line.split(); address,port=fields[1].split(':'); port=int(port,16)
  if fields[3]=='0A' and port in (5900,7900,6099): found.append((table,address,port))
assert sorted(found)==[('tcp','0100007F',5900),('tcp','0100007F',7900)],found
''')
        print('PASS only loopback VNC/noVNC, no IPv6 wildcard or X TCP', flush=True)
        run('docker', 'restart', '-t', '1', name)
        ready()
        print('PASS forced container restart recovers owned stale state', flush=True)
        execute('vnc-server', 'stop')
        result = subprocess.run(['docker','exec',name,'vnc-server','status'],capture_output=True,text=True)
        assert result.returncode == 1 and result.stdout.count('stopped/not ready') == 4, result
        execute('vnc-server', 'ensure')
        ready()
        print('PASS stop/start lifecycle', flush=True)
        # Same image, isolated opt-out container: entrypoint must not create state.
        run('docker', 'rm', '-f', name)
        run('docker', 'run', '-d', '--name', name, '--network', 'none',
            '-e', 'DEVENV_VNC_AUTOSTART=0', image)
        time.sleep(1)
        execute('test', '!', '-e', '/tmp/vnc')
        assert execute('printenv', 'DISPLAY') == ':99'
        print('PASS autostart opt-out retains DISPLAY without services', flush=True)
    finally:
        subprocess.run(['docker','rm','-f',name],capture_output=True)
        subprocess.run(['docker','image','rm',image],capture_output=True)


if __name__ == '__main__':
    main()
