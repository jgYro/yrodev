# Dependency and artifact evidence

Review date: 2026-10-28. Reviewed commit: `d5a5c8c6bc8c171676c3a32494c38c6320ccd16f`.

This is retrospective research of the unchanged project baseline. No application dependency was installed or changed. It is not a complete PASS assessment for new incorporation, for the native targets, or for every component embedded in the SDK binaries.

## Direct components

| Component | Exact resolved identity | Purpose |
| --- | --- | --- |
| Flutter SDK | 3.47.8, framework `737ba8f885dc774b53b442759999a312c9461e4e` | Application framework, compiler integration, rendering assets |
| Dart / Pub | 3.13.7, macOS arm64 | Language compiler/runtime and bundled package manager used for this checkout |
| cupertino_icons | 1.0.9 | Icon font; no CupertinoIcons references found in application code, so removal can be considered separately |
| flutter_test | SDK package from Flutter 3.47.8 | Existing widget tests |
| flutter_lints | 6.0.0 | Static-analysis configuration |

The resolved runtime closure consists of `flutter`, `sky_engine`, `cupertino_icons`, `characters`, `collection`, `material_color_utilities`, `meta`, and `vector_math`. The other 19 packages belong to development/test tooling. Flutter SDK packages have lockfile version `0.0.0`; their meaningful identity is the SDK revision, not a separately published Pub artifact.

## Complete locked graph

All hosted sources are `https://pub.dev`. Package names below link to the exact reviewed version. Current publisher identities and repository references are preserved in `evidence/pub-registry-review.json`. Per-package dependency edges and exact SHA-256 values are in `evidence/dependency-inventory.json`.

| Package | Version | Relationship / scope | Current publisher | Published | Archive + registry + lock + installed cache |
| --- | --- | --- | --- | --- | --- |
| [async](https://pub.dev/packages/async/versions/2.13.1) | 2.13.1 | transitive; development | dart.dev | 2026-03-26T00:53:13.853173Z | All matched |
| [boolean_selector](https://pub.dev/packages/boolean_selector/versions/2.1.2) | 2.1.2 | transitive; development | tools.dart.dev | 2024-10-22T08:24:19.635674Z | All matched |
| [characters](https://pub.dev/packages/characters/versions/1.4.1) | 1.4.1 | transitive; runtime | dart.dev | 2025-06-25T15:56:32.563783Z | All matched |
| [clock](https://pub.dev/packages/clock/versions/1.1.3) | 1.1.3 | transitive; development | tools.dart.dev | 2026-08-28T20:42:07.361034Z | All matched |
| [collection](https://pub.dev/packages/collection/versions/1.19.1) | 1.19.1 | transitive; runtime | dart.dev | 2024-10-21T07:34:00.994803Z | All matched |
| [cupertino_icons](https://pub.dev/packages/cupertino_icons/versions/1.0.9) | 1.0.9 | direct main; runtime | flutter.dev | 2026-03-25T12:10:06.608710Z | All matched |
| [fake_async](https://pub.dev/packages/fake_async/versions/1.3.3) | 1.3.3 | transitive; development | dart.dev | 2025-01-28T15:18:30.551930Z | All matched |
| `flutter` | 0.0.0 | direct main; runtime | Flutter SDK | SDK revision | See SDK evidence |
| [flutter_lints](https://pub.dev/packages/flutter_lints/versions/6.0.0) | 6.0.0 | direct dev; development | flutter.dev | 2025-05-27T13:59:16.618213Z | All matched |
| `flutter_test` | 0.0.0 | direct dev; development | Flutter SDK | SDK revision | See SDK evidence |
| [leak_tracker](https://pub.dev/packages/leak_tracker/versions/11.0.2) | 11.0.2 | transitive; development | tools.dart.dev | 2025-09-10T22:43:39.810799Z | All matched |
| [leak_tracker_flutter_testing](https://pub.dev/packages/leak_tracker_flutter_testing/versions/3.0.10) | 3.0.10 | transitive; development | flutter.dev | 2025-04-21T20:28:24.122862Z | All matched |
| [leak_tracker_testing](https://pub.dev/packages/leak_tracker_testing/versions/3.0.2) | 3.0.2 | transitive; development | tools.dart.dev | 2025-04-21T20:28:12.802586Z | All matched |
| [lints](https://pub.dev/packages/lints/versions/6.1.0) | 6.1.0 | transitive; development | dart.dev | 2026-01-30T21:32:30.985377Z | All matched |
| [matcher](https://pub.dev/packages/matcher/versions/0.12.20) | 0.12.20 | transitive; development | dart.dev | 2026-04-27T20:39:05.888392Z | All matched |
| [material_color_utilities](https://pub.dev/packages/material_color_utilities/versions/0.13.0) | 0.13.0 | transitive; runtime | material.io | 2025-06-04T16:40:01.638488Z | All matched |
| [meta](https://pub.dev/packages/meta/versions/1.18.3) | 1.18.3 | transitive; runtime | dart.dev | 2026-06-04T18:01:53.652200Z | All matched |
| [path](https://pub.dev/packages/path/versions/1.9.1) | 1.9.1 | transitive; development | dart.dev | 2024-10-17T08:37:58.135322Z | All matched |
| `sky_engine` | 0.0.0 | transitive; runtime | Flutter SDK | SDK revision | See SDK evidence |
| [source_span](https://pub.dev/packages/source_span/versions/1.10.2) | 1.10.2 | transitive; development | tools.dart.dev | 2026-02-05T09:07:00.222021Z | All matched |
| [stack_trace](https://pub.dev/packages/stack_trace/versions/1.12.2) | 1.12.2 | transitive; development | tools.dart.dev | 2026-08-28T20:42:47.771496Z | All matched |
| [stream_channel](https://pub.dev/packages/stream_channel/versions/2.1.4) | 2.1.4 | transitive; development | tools.dart.dev | 2025-01-07T16:38:32.361753Z | All matched |
| [string_scanner](https://pub.dev/packages/string_scanner/versions/1.4.1) | 1.4.1 | transitive; development | tools.dart.dev | 2024-12-17T10:00:43.322120Z | All matched |
| [term_glyph](https://pub.dev/packages/term_glyph/versions/1.2.2) | 1.2.2 | transitive; development | tools.dart.dev | 2024-12-17T09:33:15.487660Z | All matched |
| [test_api](https://pub.dev/packages/test_api/versions/0.7.12) | 0.7.12 | transitive; development | tools.dart.dev | 2026-04-27T20:39:09.666469Z | All matched |
| [vector_math](https://pub.dev/packages/vector_math/versions/2.4.0) | 2.4.0 | transitive; runtime | flutter.dev | 2026-06-03T20:29:49.519513Z | All matched |
| [vm_service](https://pub.dev/packages/vm_service/versions/15.4.0) | 15.4.0 | transitive; development | tools.dart.dev | 2026-10-15T17:00:24.557960Z | All matched |

## Advisory result and interpretation

- OSV query batch: 24 exact-version hosted package coordinates; 24 empty result objects. See `osv-query.json` and `osv-response.json`.
- Pub per-package advisory requests: 24 successful HTTP 200 responses; no advisories returned. Empty lists sometimes carry a 1970 timestamp indicating no advisory update. Retrieval time is recorded independently and is not inferred from that timestamp.
- GitHub reviewed Pub advisory endpoint: 14 entries, no package names overlapping the hosted inventory. The response was below the requested page size of 100. Pub relies on the GitHub database, and OSV includes overlapping sources; these sources are not fully independent.
- Upstream Dart SDK: 8 published advisories reviewed; installed stable versions are at or above the listed fixed thresholds. The recent high-severity native TLS issue is fixed in the exact installed versions. Flutter repository advisories were also retrieved.

No known issues found in these checks. Coverage does not extend to a verified complete SBOM/advisory map for every linked WebAssembly/native component.

## Artifact inspection

All 24 exact-version archives were downloaded as data. All archive hashes matched the registry metadata and lockfile. Across 1,690 regular archive files, the inspection found no file-content or missing-file mismatch against the installed package cache. It did not look for extra cache files absent from the published archives, and it did not attest the integrity of the entire SDK or operating system.

The archive check inspected names, types, manifests, hook/bin paths, native executable extensions, and a small set of code signals. No unsafe paths, special entries, declared hook fields, or native executable artifacts were found by these checks. This is not an exhaustive malware review.

Signal triage:

| Package / area | Observation | Assessment for this site |
| --- | --- | --- |
| boolean_selector tests | `_eval` helper matches a broad eval search | Dart test helper, not dynamic JavaScript evaluation |
| characters tool/src/shared.dart | HttpClient for generation tooling | Not called by application imports; not executed during review |
| cupertino_icons tests | Reads CHANNEL environment setting | Test configuration, not browser credential collection |
| leak_tracker test support | HTTP helper | Development test infrastructure, not imported by the site |
| term_glyph generator | Executes a generation subprocess | Explicit maintenance tool, not an install hook |
| vector_math bin/mesh_generator.dart | Explicit geometry-generation CLI | No application call site; no automatic hook found |
| vm_service tests/examples/generator | Subprocess, VM service, and HTTP test utilities | Development dependency; no app import or browser endpoint found |

## Origin and provenance

Registry metadata identifies publishers `dart.dev`, `tools.dart.dev`, `flutter.dev`, and `material.io`, with repositories in the corresponding Dart, Flutter, and Material projects. Names match the lockfile exactly. No private-registry fallback or private package-name collision exists in this graph.

The official Flutter tag resolves to the installed framework revision, and upstream DEPS bytes match the local SDK. The selected Skia, Dart, HarfBuzz, FreeType, JPEG, PNG, WebP, zlib, and Expat source pins are in `engine-origin-review.json`. These declarations are not a verified linked-component manifest for the shipped CanvasKit variants.

Historical ownership-transfer investigation, signature/attestation verification binding published artifacts to source and build workflows, and full SDK-binary provenance verification remain incomplete. No claim of benign provenance follows merely from a verified publisher domain, hash match, or empty advisory response.

## Native declarations and unresolved scope

| Component | Declared identity | Coverage |
| --- | --- | --- |
| Gradle distribution | 9.3.1-all.zip at services.gradle.org | URL inspected; checksum not configured; not downloaded or executed |
| Android Gradle Plugin | 9.1.0 at Google Maven | Manifest declaration only; transitive graph not resolved |
| Kotlin Android plugin | 2.4.0 at configured Gradle repositories | Manifest declaration only; transitive graph not resolved |
| Flutter plugin loader | 1.0.0 with local SDK included build | SDK-selected build code; native execution not assessed |
| Android SDK / NDK / JDK | Determined partly by Flutter and local build environment | Concrete native deployment graph not established |
| Apple / desktop builds | Generated platform scaffolding | Configuration review only; no built binary, signing, or platform runtime audit |

## Reproduction tools

Python 3.14.2 standard library was used for data parsing, hashing, tar inspection, and evidence generation. curl 8.7.1 retrieved public metadata/artifacts. The existing Playwright MCP server provided Chromium 156.0.8078.48 browser automation. These are review tools, not added application dependencies.

The package inspection script records current retrieval times and status per endpoint. Archive hashes are reproducible against the lockfile. Advisory databases change; rerunning a query later can legitimately produce different results. No private source or private package inventory was sent to a public scanner; the OSV request contains public package coordinates only.
