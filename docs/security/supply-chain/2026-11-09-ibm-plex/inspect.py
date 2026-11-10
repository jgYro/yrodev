import hashlib
import json
import re
import struct
from pathlib import Path

p = Path(__file__).parent
commit = json.loads((p / 'commit.json').read_text())
tree = json.loads((p / 'tree.json').read_text())
assert not tree['truncated']
directories = {}
for entry in tree['tree']:
    parent, _, name = entry['path'].rpartition('/')
    directories.setdefault(parent, []).append((name, entry))
for parent, entries in directories.items():
    contents = b''.join((entry['mode'].lstrip('0') + ' ').encode() + name.encode() + b'\0' + bytes.fromhex(entry['sha'])
        for name, entry in sorted(entries, key=lambda x: x[0] + ('/' if x[1]['type'] == 'tree' else '')))
    digest = hashlib.sha1(b'tree ' + str(len(contents)).encode() + b'\0' + contents).hexdigest()
    expected = commit['commit']['tree']['sha'] if parent == '' else next(e['sha'] for e in tree['tree'] if e['path'] == parent)
    assert digest == expected, parent
root_tree = commit['commit']['tree']['sha']
payload = (p / 'commit.payload').read_text()
assert payload.startswith('tree ' + root_tree + '\n')
signature = (p / 'commit.sig').read_text()
headers, message = payload.split('\n\n', 1)
signed = headers + '\ngpgsig ' + signature.replace('\n', '\n ') + '\n\n' + message
raw = signed.encode()
assert hashlib.sha1(b'commit ' + str(len(raw)).encode() + b'\0' + raw).hexdigest() == commit['sha']

def checksum(data):
    padded = data + bytes((-len(data)) % 4)
    return sum(struct.unpack('>' + 'I' * (len(padded) // 4), padded)) & 0xffffffff

inventory = []
for file in sorted(p.glob('*.ttf')):
    data = file.read_bytes()
    entry = next(e for e in tree['tree'] if e['path'].endswith('/' + file.name))
    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    assert blob == entry['sha'] and len(data) == entry['size']
    assert data[:4] == b'\0\1\0\0'
    count = struct.unpack_from('>H', data, 4)[0]
    tables = {}
    for i in range(count):
        tag, expected, offset, length = struct.unpack_from('>4sIII', data, 12 + i * 16)
        assert offset + length <= len(data)
        table = data[offset:offset+length]
        if tag == b'head': table = table[:8] + bytes(4) + table[12:]
        assert checksum(table) == expected, (file.name, tag)
        tables[tag.decode()] = {'offset':offset,'length':length}
    assert checksum(data) == 0xb1b0afba
    names = []
    start = tables['name']['offset']
    _, name_count, storage = struct.unpack_from('>HHH',data,start)
    for i in range(name_count):
        platform, encoding, language, name_id, length, offset = struct.unpack_from('>HHHHHH',data,start+6+i*12)
        value=data[start+storage+offset:start+storage+offset+length]
        if platform in [0,3]: value=value.decode('utf-16-be', errors='replace')
        else: value=value.decode('latin-1', errors='replace')
        if name_id in [1,2,5,8,9,13,14] and (name_id,value) not in names:names.append((name_id,value))
    inventory.append({'file':file.name,'source_path':entry['path'],'bytes':len(data),'git_blob_sha1':blob,'sha256':hashlib.sha256(data).hexdigest(),'tables':tables,'names':names,'embedded_web_or_bitmap_tables':[t for t in ['SVG ','EBDT','CBDT','sbix'] if t in tables],'hinting_tables':{t:tables[t]['length'] for t in ['fpgm','prep','cvt '] if t in tables}})
result={'commit':commit['sha'],'tree':root_tree,'all_tree_hashes_verified':True,'commit_hash_verified':True,'files':inventory}
(p/'inventory.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'commit':result['commit'],'verified_files':[{k:f[k] for k in ['file','bytes','sha256','hinting_tables','embedded_web_or_bitmap_tables']}|{'version':[v for n,v in f['names'] if n==5]} for f in inventory]},indent=2))
