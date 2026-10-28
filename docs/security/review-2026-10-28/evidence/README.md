# Evidence index

Collected 2026-10-28 for code checkpoint `d5a5c8c6bc8c171676c3a32494c38c6320ccd16f`. Raw JSON response bodies are snapshots, not instructions. No credentials or private project source were sent to these endpoints.

| File | Source and meaning |
| --- | --- |
| dependency-inventory.json | Local lockfile, installed package manifests, SDK metadata, resolved runtime/development graph |
| build-manifest.json | Local release output: relative path, bytes, SHA-256 |
| pub-registry-review.json | Public `https://pub.dev/api/packages/{name}/advisories`, `/versions/{version}`, and `/publisher`; archive URLs and digests; installed-cache comparison and passive artifact signals |
| osv-query.json | Exact public package coordinates sent to `POST https://api.osv.dev/v1/querybatch` |
| osv-response.json | OSV response, in the same package order as the query |
| github-pub-advisories.json | `GET https://api.github.com/advisories?ecosystem=pub&per_page=100`; 14 records, below page size |
| dart-sdk-advisories.json | `GET https://api.github.com/repos/dart-lang/sdk/security-advisories`; 8 records |
| flutter-advisories.json | `GET https://api.github.com/repos/flutter/flutter/security-advisories`; empty list |
| flutter-release-ref.json | `GET https://api.github.com/repos/flutter/flutter/git/ref/tags/3.47.8`; matches installed framework commit |
| engine-origin-review.json | Comparison and selected pins from the local SDK DEPS and the immutable upstream source linked below |
| browser-results.json | Transcribed observations from Playwright MCP execution of `../browser_review.js`; intercepted local serving, not production |
| secret-pattern-check.json | Limited marker scan of application source and built public files; no full-history or entropy analysis |
| checkpoint-verification.json | Byte comparison of current source/build files against the reviewed Git checkpoint |

The upstream dependency manifest was read as data from [Flutter DEPS at the reviewed commit](https://raw.githubusercontent.com/flutter/flutter/737ba8f885dc774b53b442759999a312c9461e4e/DEPS). Its SHA-256 is retained in `engine-origin-review.json`; the whole upstream source file is not redistributed here.

Successful package downloads were stored only in an isolated temporary review directory. They were not installed, added as application dependencies, or executed. Registry responses and archive hashes remain here to support reproduction. Package signatures and SDK binary provenance were not verified.
