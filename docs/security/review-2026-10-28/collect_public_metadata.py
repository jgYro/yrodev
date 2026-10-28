"""Passive review: fetch public metadata/artifacts as data; execute no package code."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.parse import urlparse, unquote
import datetime
import hashlib
import io
import json
import re
import subprocess
import sys
import tarfile

ROOT = Path(__file__).resolve().parents[3]
EVIDENCE = Path(__file__).resolve().parent / 'evidence'
REVIEW_CACHE = Path('/private/tmp/yro-security-artifacts')
REVIEW_CACHE.mkdir(exist_ok=True)
inventory = json.loads((EVIDENCE / 'dependency-inventory.json').read_text())
config = json.loads((ROOT / '.dart_tool/package_config.json').read_text())
cache_dirs = {p['name']: Path(unquote(urlparse(p['rootUri']).path)) for p in config['packages']}


def fetch(url, output):
    if '--offline' in sys.argv:
        statuses = {}
        for status_file in REVIEW_CACHE.glob('*-transfer-status.txt'):
            for line in status_file.read_text().splitlines():
                parts = line.split(' ', 1)
                if len(parts) == 2 and (parts[1] not in statuses or parts[0] == '200'):
                    statuses[parts[1]] = parts[0]
        status = statuses.get(url, '000')
        return {'url': url, 'http_status': status,
                'exit_code': 0 if output.is_file() and status == '200' else 1,
                'error': '' if status == '200' else 'No successful recorded transfer'}
    result = subprocess.run(
        ['curl', '--silent', '--show-error', '--location', '--max-time', '25',
         '--output', str(output), '--write-out', '%{http_code}', url],
        capture_output=True, text=True,
    )
    return {'url': url, 'http_status': result.stdout.strip(),
            'exit_code': result.returncode, 'error': result.stderr.strip()[:500]}


def review(package):
    name, version = package['name'], package['version']
    record = {'name': name, 'version': version, 'scope': package['scope']}
    for label, url in (
        ('advisories', f'https://pub.dev/api/packages/{name}/advisories'),
        ('metadata', f'https://pub.dev/api/packages/{name}/versions/{version}'),
        ('publisher', f'https://pub.dev/api/packages/{name}/publisher'),
    ):
        output = REVIEW_CACHE / f'{name}-{label}.json'
        status = fetch(url, output)
        record[label + '_request'] = status
        if status['http_status'] == '200' and status['exit_code'] == 0:
            try:
                record[label] = json.loads(output.read_text())
            except (ValueError, OSError) as exc:
                record[label + '_parse_error'] = str(exc)
    metadata = record.get('metadata', {})
    archive_url = metadata.get('archive_url', '')
    if not archive_url.startswith('https://pub.dev/api/archives/'):
        record['archive_review'] = {'status': 'not fetched', 'reason': 'missing or unexpected archive URL'}
        return record
    archive = REVIEW_CACHE / f'{name}-{version}.tar.gz'
    request = fetch(archive_url, archive)
    record['archive_request'] = request
    if request['http_status'] != '200' or request['exit_code'] != 0:
        return record
    data = archive.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    review = {
        'sha256': digest, 'bytes': len(data),
        'matches_lock': digest == package['lock_sha256'],
        'matches_registry': digest == metadata.get('archive_sha256'),
        'cache_mismatches': [], 'special_entries': [], 'execution_entries': [],
        'manifest_hook_fields': [], 'code_signal_files': [], 'regular_files': 0,
    }
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as tar:
        for member in tar.getmembers():
            member_path = Path(member.name)
            if member_path.is_absolute() or '..' in member_path.parts:
                review['special_entries'].append({'path': member.name, 'type': 'unsafe path'})
                continue
            if not member.isfile():
                if not member.isdir():
                    review['special_entries'].append({'path': member.name, 'type': str(member.type)})
                continue
            review['regular_files'] += 1
            body = tar.extractfile(member).read()
            cached = cache_dirs[name] / member.name
            if not cached.is_file() or hashlib.sha256(cached.read_bytes()).digest() != hashlib.sha256(body).digest():
                review['cache_mismatches'].append(member.name)
            if member_path.parts[0] in ('hook', 'bin') or member_path.suffix in ('.so', '.dll', '.dylib', '.exe', '.wasm'):
                review['execution_entries'].append(member.name)
            if member.name == 'pubspec.yaml':
                review['manifest_hook_fields'] = re.findall(r'^(hooks|executables|native_assets|ffi|plugins?):.*$', body.decode(errors='replace'), re.M)
            if member_path.suffix in ('.dart', '.js', '.sh', '.py') and re.search(rb'Process\.(run|start)|Platform\.environment|HttpClient\(|dynamicLibrary|DynamicLibrary\.open|eval\(', body):
                review['code_signal_files'].append(member.name)
    record['archive_review'] = review
    return record


hosted = [p for p in inventory['packages'] if p['source'] == 'hosted']
with ThreadPoolExecutor(max_workers=6) as pool:
    records = list(pool.map(review, hosted))
result = {'checked_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'packages': records}
(EVIDENCE / 'pub-registry-review.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({
    'packages': len(records),
    'advisory_requests_ok': sum(p.get('advisories_request', {}).get('http_status') == '200' for p in records),
    'integrity_matches': sum(p.get('archive_review', {}).get('matches_lock', False) and p.get('archive_review', {}).get('matches_registry', False) for p in records),
    'cache_mismatch_packages': [p['name'] for p in records if p.get('archive_review', {}).get('cache_mismatches')],
    'packages_with_advisories': [p['name'] for p in records if p.get('advisories', {}).get('advisories')],
    'incomplete': [p['name'] for p in records if not p.get('archive_review', {}).get('matches_lock', False)],
}, indent=2))
