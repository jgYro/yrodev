# IBM Plex font assessment

Date: 2026-11-09. **Decision: PASS for the four unmodified, pinned TTF font assets listed in inventory.json, plus their OFL license.** No known issues found in the checks performed. This decision does not approve the upstream npm packages, telemetry tool, repository build dependencies, or arbitrary future font releases.

## Scope and complete added inventory

The user requested IBM Plex typography for Yro. Existing system fonts do not fulfill that request. Only four static font files are vendored into `assets/fonts/ibm-plex/` and declared in Flutter's asset manifest:

| Component | Embedded font version | Purpose | SHA-256 |
| --- | --- | --- | --- |
| IBM Plex Sans Regular | 3.005 | Body text, weight 400 | `975dcda37d80f038dcd143c22e33ca2d97a0cc5a929aace1c749153b0fe1afa5` |
| IBM Plex Sans Medium | 3.005 | Headings, weight 500 | `331c8639d7598b2cde62a911a71db195e30cb655cd6bdf2e324a7e984955f907` |
| IBM Plex Sans SemiBold | 3.005 | Hero/strong text, weight 600 | `a20caf8286023a6a7a85e40b1d2a4ae9fc3e3b1f9eda8f4c542dd4986af67bb1` |
| IBM Plex Mono Regular | 2.005 | Navigation and technical labels, weight 400 | `7c6fbddca4b700be918f5f6183d9bd4464fa427fe435f0b480d77fe2bb8c5a43` |

Exact source commit: `48e8676114c04f29033b4b53da4ec579f8846297` in [IBM/plex](https://github.com/IBM/plex/commit/48e8676114c04f29033b4b53da4ec579f8846297). Font paths, file sizes, Git blob identities, all SFNT tables and embedded metadata are in [inventory.json](inventory.json). Total font bytes: 778644. The upstream package manifests call these families `@ibm/plex-sans@1.1.0` and `@ibm/plex-mono@2.5.0`; those package versions differ from embedded font revision numbers.

The added runtime dependency graph is four font assets → the project's existing Flutter/browser font renderer. There are no new transitive, peer, optional, development, native-binary, container, or downloaded second-stage dependencies. These fonts include their glyph outlines, layout data, and TrueType hinting bytecode; those embedded tables are included in the inventory. The deployment target remains Firebase static web on browser OS/architectures supported by the existing build. The fonts are platform-neutral assets; no native runtime target or renderer is changed. Existing Flutter/Dart and locked Pub dependencies remain unchanged. No package manager installs are required.

## Identity, integrity, and provenance

[IBM's typography site](https://www.ibm.com/plex/) links directly to `IBM/plex`. Retrieval used the exact commit via `raw.githubusercontent.com/IBM/plex/<commit>/packages/<family>/fonts/complete/ttf/<file>`, with TLS verification. A complete recursive Git tree was retrieved as inert JSON. The review recomputed every directory tree hash, bound the root tree `e2401ee5cf09dc98d334565238c570cb3fec38aa` to the signed commit payload, reconstructed the commit hash, and verified each font blob and size against that tree. All four SFNT whole-file and per-table checksums also passed. The license and family manifests matched their source-tree blob hashes.

GnuPG cryptographically verified the commit's detached signature and payload using GitHub's public web-flow key fetched from `https://github.com/web-flow.gpg`: fingerprint `968479A1AFF927E37D1A566BB5690EEEBB952194`, result `GOODSIG` and `VALIDSIG`. This is verification of GitHub's source-commit signature, not an attestation of how font binaries were built. The local keyring has no independent web-of-trust certification; key origin is authenticated GitHub HTTPS. Signature, payload, key, and verification output are preserved. No separately signed font-binary build provenance or reproducible font-build verification was available/performed. Alternative origin evidence is IBM's official repository link, the verified signed commit/tree/blob chain, and pinned checksums. These do not prove benign behavior.

The reviewed current source commit addresses upstream build-tool dependency alerts. Release metadata includes separately versioned font families, consistent with the repository's package layout; Mono 2.5.0 was released 2026-06-11. No ownership/namespace change or credible malicious font-release report was found in the reviewed official sources and targeted compromise searches. This is not an exhaustive historical ownership audit.

## Current security checks and material findings

- npm's advisory service was queried for the public family coordinates/versions above and returned `{}`. OSV's batch service was independently queried for both package coordinates and the exact source commit; all three returned empty results. Responses are preserved. These checks are supporting intelligence, not proof that a data-only font artifact is free of parser-triggering flaws; the TTF revisions have no distinct npm advisory coordinate.
- [Upstream security policy/advisories](https://github.com/IBM/plex/security) reported no published project advisory. Targeted searches for IBM Plex font compromise, malware, and CVEs did not identify a confirmed match to these fonts. Unrelated Plex Media Server findings are not font findings.
- [Upstream issue 721](https://github.com/IBM/plex/issues/721) contains dependency alerts in the font repository's development/build tooling (including form-data CVE-2025-7783, braces CVE-2024-4068, ws CVE-2024-37890, axios CVE-2024-39338/CVE-2025-27152/CVE-2025-58754, and additional JS build/server tooling). These packages are not present in the four reviewed SFNT files and are neither installed nor executed for this integration. Their exploit paths—HTTP handling, archive extraction, JS execution, build tooling—are absent from the incorporated artifact graph. The issue's dependency alerts therefore do not match this intended use; no claim is made that the full upstream npm/build graph is clean.
- Both upstream family package manifests declare `@ibm/telemetry-js: ^1.6.1` and a `postinstall` command invoking `ibmtelemetry`. Those packages/scripts are deliberately excluded from the reviewed artifact scope. Direct fonts require no scripts, telemetry, npm, or yarn. No candidate package code was executed.

## Static behavior and license review

Inspection treated the downloads as bytes: checked SFNT magic, all table offsets/lengths, all table checksums, whole-font checksum, family/version/publisher/license records, and table types. No SVG/embedded-web or bitmap payload tables were present. Font program (`fpgm`), preparation (`prep`), control values (`cvt `), glyph outlines (`glyf`), and ordinary shaping/positioning tables are inventoried. They are interpreted by the existing renderer after approval. Hinting/shaping programs were not exhaustively disassembled and there was no full renderer exploit analysis; that is a remaining coverage limitation, not evidence of suspicious behavior. The files have no package hooks, network destinations that execute, subprocesses, credential access, persistence, external resources, or second-stage downloads. License/publisher URLs in font metadata are inert strings.

IBM's SIL Open Font License 1.1 permits bundling/embedding. The unmodified license and copyright notice accompany the unmodified font files; reserved names are preserved. No font conversion, subsetting, or rebuilding is performed. The page will self-host the fonts instead of adding a third-party stylesheet/runtime.

## Reproduction and controls

Inspection tools: Python 3.14.2 standard library (`json`, `struct`, `hashlib`); system curl 8.7.1; GnuPG 2.4.9; existing Flutter 3.47.8 / Dart 3.13.7. No application package manager is invoked for the font addition. The unchanged runtime and lockfile remain covered by their prior records; existing assistant review tools are outside the program dependency gate.

Download `commit.json` from GitHub's `repos/IBM/plex/commits/<commit>` endpoint and `tree.json` from `repos/IBM/plex/git/trees/<commit>?recursive=1`, plus the four fonts at the pinned paths and the saved signature/payload, into a review directory; run the saved `inspect.py` there. Verify the saved signature with the included key in an isolated GPG keyring. Recheck font SHA-256 values after copying into the project. Keep the assessment and inventory with the font assets. Reassess changed bytes, versions, sources, rendering/runtime scope, or material new compromise evidence.

Assessment completed before first incorporation or font rendering. No exception is required for this bounded PASS.
