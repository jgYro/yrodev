# Yro LLC site: security review

**Reviewed:** 2026-10-28. **Code checkpoint:** `d5a5c8c6bc8c171676c3a32494c38c6320ccd16f`.

The checkpoint was committed before this analysis. It contains the source snapshot in `source/` and the release website in `dist/` within `.site/yro-overview`. Root source files and `build/web` were checked against that snapshot. No application code, dependencies, or deployment settings were changed during this review.

## Assessment

**No exploitable high- or critical-severity issue was confirmed in the reviewed website.** The application is a static business overview with no authentication, backend, forms, uploads, database, or payment processing. Its small amount of browser interop uses fixed destinations. No attacker-controlled input was found reaching an application HTML, script, shell, or database execution sink.

There are concrete release-control gaps. Android release builds are configured to use debug signing. The repository does not define a browser security-header policy, and the deployed host has not been verified. Build provenance and native dependency coverage are also incomplete. These conditions are described separately from vulnerabilities that a remote website visitor can exploit today.

This is a source, artifact, dependency, and controlled-browser review. It is not a production penetration test, a claim that the software is vulnerability-free, or a full supply-chain PASS for a new dependency or native release.

| ID | Priority | Observation | Applicability |
| --- | --- | --- | --- |
| YRO-01 | Medium, conditional | Android release configuration uses debug signing | Before distributing a native Android release; no impact on the current web artifact |
| YRO-02 | Low | Security headers are not defined by the repository | Production exposure depends on the hosting service's actual response headers |
| YRO-03 | Low | Toolchain selection and download verification are not fully enforced | Build and release assurance; no compromise was demonstrated |

Severity reflects the demonstrated conditions and this site's actual data and functionality. No speculative CVSS scores are assigned.

## Findings

### YRO-01: Android release configuration selects the debug signing key

**Evidence:** `android/app/build.gradle.kts:32`, specifically line 36:

```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")
}
```

A native release built from this configuration uses the development signing identity. That is unsuitable as the controlled identity for distributing and updating a production application. Development keys tend to have different storage, access, and lifecycle controls from production signing keys. Possession of the corresponding private key can undermine the identity of applications signed with it; this review did not discover that key or demonstrate its compromise. Debug signing does not, by itself, prove that a release binary has debugging enabled.

**Conditions:** An Android artifact must actually be built and distributed. None was built or assessed here. The browser website does not use Android signing. This is a native release blocker rather than a remote web vulnerability.

**Recommendation:** Before Android distribution, establish a production signing configuration, keep key material outside version control, and have release builds fail when signing credentials are unavailable. Verify the certificate on the resulting APK/AAB against the intended release identity. If Android is not a supported deliverable, document that status so this scaffold cannot be mistaken for release-ready code. See [Android's app-signing guidance](https://developer.android.com/studio/publish/app-signing).

### YRO-02: Repository does not establish a security-header policy

**Evidence:** `web/index.html:3` contains no CSP meta policy. `web/flutter_bootstrap.js:3` starts the renderer without a deployment policy. `.site/yro-overview/.openai/hosting.json:3` selects `dist` but defines no response headers. These observations do **not** establish what the hosting platform adds automatically.

In a controlled browser test serving these bytes without extra headers, a different origin could frame the page. A tested response policy blocked the frame and still allowed the Flutter application to render. Current framing impact is limited because the site has no authenticated account or sensitive transaction to manipulate. A missing CSP is defense-in-depth debt, not evidence of an existing XSS vulnerability.

**Recommendation:** Inspect the actual production HTML and asset response headers. Where absent, configure the host with the tested candidate below. The `frame-ancestors` directive must be sent as an HTTP response header; it is not supported in a CSP meta element. [MDN: CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy), [MDN: frame-ancestors](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/frame-ancestors).

```http
Content-Security-Policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; font-src 'self'; connect-src 'self'; worker-src 'self' blob:; object-src 'none'; base-uri 'self'; form-action 'none'; frame-ancestors 'none'
X-Content-Type-Options: nosniff
Referrer-Policy: no-referrer
X-Frame-Options: DENY
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

This is a candidate configuration, not an applied fix. It rendered the reviewed build in Chromium 156.0.8078.48 without console or page errors. It permits WebAssembly compilation and the inline styles needed by this UI, without allowing general JavaScript `unsafe-eval` or inline scripts. It still permits same-origin scripts, so it does not neutralize an attacker who can replace the site's own JavaScript. Verify navigation, contact actions, renderer variants, and target browsers on the real host before enforcing it. It intentionally blocks unapproved external font connections.

HTTPS redirects, certificate configuration, HSTS, cache behavior, and MIME types remain production checks. HSTS scope and preload decisions should follow confirmation of the domain and subdomain configuration. Intercepted HTTPS test URLs did not test real TLS.

### YRO-03: Toolchain and download integrity are recorded but not fully enforced

**Evidence:** `.metadata:7` records a Flutter revision. `pubspec.yaml:22` permits Dart `^3.13.7`. `pubspec.lock` records exact hosted package versions and SHA-256 hashes. No checked-in build mechanism enforces the exact Flutter framework/engine revision. `android/gradle/wrapper/gradle-wrapper.properties:5` pins Gradle 9.3.1's URL but has no `distributionSha256Sum`.

The current framework revision matches the official Flutter 3.47.8 tag, and all 24 Pub archives matched both their lockfile and registry hashes. The gap concerns a future build resolving or fetching different toolchain bytes, not evidence that the present build is altered. Recording a version in Flutter's migration metadata is not the same as enforcing it in a build.

**Recommendation:** Record and enforce the approved SDK revision in the release process, use the existing lockfile without resolution drift, and retain build hashes with the release. Before native Gradle use, add an independently checked distribution checksum and verify the wrapper artifact. Resolve and assess the native plugin/transitive graph before treating native builds as approved. Gradle documents both [distribution and wrapper verification](https://docs.gradle.org/current/userguide/gradle_wrapper.html#sec:verification).

The independently authenticated build provenance of the SDK binaries was not verified here. A matching upstream tag and package hashes establish useful origin and consistency evidence; they do not prove benign code or a trustworthy build machine.

## Application and browser analysis

The main trust boundaries are the source/build process, the static hosting origin, the visitor's browser, and an explicitly opened external destination. The site does not process a customer's technical requirements, email message, account credentials, or business data. Clicking the contact button delegates a fixed `mailto:business@yro.dev` URI to the browser's configured handler.

| Area | Evidence and conclusion |
| --- | --- |
| DOM and URL injection | `lib/external_link_target_web.dart:10` creates an anchor and sets attributes. Both callers, `lib/site.dart:583` and `:600`, provide the constant `https://tunings.io/`. `lib/contact.dart:7` supplies the fixed mail address to `window.location.assign`. No application query, fragment, `postMessage`, or remote-content input is consumed by these paths. |
| Future URL validation | The generic link and mail helpers accept strings without scheme validation. This is not currently exploitable because their inputs are constants. If content later comes from a CMS, configuration service, or user input, validate allowed schemes and hosts before these sinks. A blanket claim that the current helper is an XSS or open-redirect vulnerability would be unsupported. |
| External navigation | Both DOM anchors have `target="_blank"` and `rel="noopener noreferrer"`. Mouse and Enter activation of the text link produced a separate destination with a null opener, no Referer header, and the parent page unchanged. The destination response was intercepted locally for this test. |
| Keyboard handler | `web/external_links.js:3` only stops propagation when an event's composed path includes the site's marked native anchor. It does not cancel default navigation, record typed data, or transmit events. |
| Network behavior | Normal load and all four chapter navigation actions produced 13 same-origin GET requests, including local renderer, fonts, and preview image. No third-party request, analytics endpoint, or application API call was observed. |
| Storage and persistence | A new browser context had no cookies, local/session storage entries, IndexedDB databases, Cache Storage entries, or service-worker registrations after navigation. The shipped `flutter_service_worker.js` unregisters itself if activated; it contains no fetch-caching implementation. |
| Bounded input checks | HTML markers in the query and fragment, plus a `javascript:` URL parameter, were neither rendered in the DOM nor executed. This corroborates the source review but is not comprehensive fuzzing. |
| Portfolio preview | The Tunings preview is a local PNG. The page embeds no third-party iframe and runs no Tunings code until the visitor opens the link. |
| Secret exposure | A limited scan of 62 application/web/artifact files found no tested private-key, GitHub-token, AWS-key, Google-API-key, or local home-path patterns. An earlier checkpoint scan also found no matching key/token markers. These were pattern scans, not full secret detection or historical forensics. The public email is intentional. |
| Native scaffold | macOS release entitlements enable the app sandbox. JIT and server-network entitlements are in the debug/profile file. The Android launcher being exported is expected. No custom native data-handling or security-sensitive business logic was found. Native binaries and runtime behavior were not tested. |

The compiled Flutter runtime contains a Google Fonts fallback URL. That code path was not observed in this test because the shipped fonts covered the page. Different glyphs or future content can change that behavior. The proposed CSP confines font/network loading to the same origin; a permanent self-hosting guarantee would require testing all supported content and renderer configurations.

There is no application authorization, CSRF, SQL injection, SSRF, file-upload, or server-side command surface to test in this implementation. Adding services later changes that conclusion. Generic framework functions in compiled output are not, by themselves, proof that these attack surfaces exist. Flutter also documents [common scanner false positives](https://docs.flutter.dev/reference/security-false-positives).

## Dependency and artifact research

The resolved lockfile has **27 packages: 24 hosted packages and 3 Flutter SDK packages**. Eight packages are in the runtime dependency closure; the remaining 19 are development-only in this project. A transitive package used by the runtime is classified as runtime even if tests also use it. Exact identities, graph edges, hashes, publisher metadata, dates, and observations are retained in [DEPENDENCIES.md](DEPENDENCIES.md) and the evidence files.

The actual SDK is Flutter **3.47.8**, framework `737ba8f885dc774b53b442759999a312c9461e4e`, engine `cf636b1dfb818dd6a3ff16e390e93b1a036969c8`, and Dart **3.13.7** on macOS arm64. The website is a Dart-to-JavaScript build with local CanvasKit/WebAssembly assets, rather than an Android or native desktop binary.

Checks completed on 2026-10-28:

- Queried OSV using every hosted package's exact name and version. All 24 responses contained no matching vulnerabilities.
- Queried Pub's per-package advisories for all 24 packages. All returned HTTP 200 with empty advisory lists. Also retrieved the GitHub Pub advisory list and found no overlapping package names among its 14 entries. Pub uses the GitHub Advisory Database, and OSV ingests overlapping sources, so these are not wholly independent discoveries. [Dart advisory documentation](https://dart.dev/tools/pub/security-advisories).
- Retrieved each exact published archive as data, without installing or executing it. All 24 SHA-256 values matched both the lockfile and registry metadata. All 1,690 regular archive files matched their installed-cache counterparts. No unsafe archive paths or special entries were found by this check.
- Inspected archive manifests and execution-related paths. No `hook/` entries, native executables, or declared hook fields were found by the recorded scan. `vector_math` contains an explicit mesh-generation CLI. Development/test generators include subprocess and network operations; these were not executed by the review and are not imported by this website. Signal searches and targeted reading are not exhaustive malware analysis.
- Confirmed the official Flutter 3.47.8 Git tag points to the recorded framework commit. The installed SDK's top-level `DEPS` matches the file retrieved at that commit. Selected engine dependency pins were recorded separately from the Pub graph.

One especially relevant current upstream advisory is **GHSA-frr6-h895-5pxp**, published October 23, 2026, concerning compromised eMudhra intermediate certificates in native Dart TLS. Its stable fixes are Dart 3.13.7 and Flutter 3.47.8, exactly the versions installed here. The reviewed web application also uses browser networking rather than native `dart:io` TLS. It is therefore **not a confirmed vulnerability in this build**. [Upstream advisory](https://github.com/dart-lang/sdk/security/advisories/GHSA-frr6-h895-5pxp).

The other seven published Dart SDK advisories retrieved in this review have fixed-version thresholds below the installed SDK, including **GHSA-q739-79rh-vmvp / CVE-2026-27704**, a Pub archive-extraction issue fixed in Dart 3.11.0 / Flutter 3.41.0. Flutter's own repository advisory list was empty; Dart's advisory list was also checked because it contains Flutter-affecting issues. [Dart SDK advisories](https://github.com/dart-lang/sdk/security/advisories).

**Result:** No known issues found in the exact hosted-package and upstream SDK advisory checks performed. No artifact-integrity mismatch was found. This does not establish that all embedded native/WebAssembly components are free of known vulnerabilities. No component was added, updated, or approved for new use.

## Coverage and limitations

- The web output has 43 files totaling 41,906,639 bytes. [build-manifest.json](evidence/build-manifest.json) records their hashes. The reviewed current snapshot is covered, not every historical commit or the developer's host.
- Production was not reached or verified. DNS, CDN behavior, TLS, access control of hosting accounts, domain ownership controls, deployment credentials, response headers, caching, exposed source directories, and rollback mechanisms remain outside demonstrated coverage. The configured public directory is `dist`, not `source` or these review documents.
- CanvasKit/skwasm/wimp binaries and fonts are supplied by the SDK. Their file hashes and selected upstream source pins are recorded, but a complete linked-component SBOM, binary-to-source provenance verification, embedded-library advisory mapping, and binary reverse engineering were not completed.
- Android declares Gradle 9.3.1, Android Gradle Plugin 9.1.0, and Kotlin plugin 2.4.0. Native transitive dependencies, SDK/NDK/JDK identities, Apple signing, and native release artifacts were not resolved or executed. This review is not an approval of that graph.
- Registry publisher identities and canonical repository references were checked. Historical ownership transfers and cryptographically verified publishing attestations were not established. HTTPS metadata and matching hashes are consistency evidence, not independent proof of benign release provenance.
- Broad upstream compromise searches did not establish a relevant malicious release. Search coverage and advisory coverage are incomplete by nature; no malware-free claim is made.
- Browser security checks used the existing Playwright MCP server and Chromium 156.0.8078.48 with a clean context. Firefox, Safari, actual native mail clients, and native clipboard behavior were not exercised. Previous successful Dart analysis and web-build results are recorded in `docs/validation.md`; no application changes warranted repeating them. Widget tests remain unverified because the environment denies their loopback socket.
- Initial batched metadata retrieval failed DNS resolution. Explicit per-endpoint retries then returned HTTP 200 for all 72 metadata/advisory/publisher requests and all 24 archives. Only successful retrieved bodies were used for final package conclusions. A separate Flutter release-archive metadata request returned 404; the official Git tag and immutable source file were verified instead. That alternative is not binary provenance verification.

## Recommended order of work

1. Before public deployment, verify the real host's security headers and publish a tested policy where needed. Confirm HTTPS, MIME types, cache behavior, and that only `dist` is served.
2. Before any Android release, replace debug signing with a controlled release identity or explicitly remove Android from supported release targets.
3. Make the approved SDK and locked dependency graph reproducible in the release process. Complete the native/embedded dependency assessment if those targets or stronger supply-chain assurance are required.
4. Preserve the current fixed-destination design. Introduce URL validation and a new input/data-flow review if dynamic portfolio entries, forms, authentication, analytics, or APIs are added.

## Reproduction and evidence

`browser_review.js` is a standalone snippet for the existing Playwright MCP `browser_run_code_unsafe` tool. It serves local build bytes using route interception, tests the baseline and proposed headers, and closes its isolated context. Adjust its local project path when reviewing another checkout. [Recorded browser observations](evidence/browser-results.json).

`collect_public_metadata.py` is a standard-library-only passive inspection script. It fetches public package metadata and archives, compares hashes and installed cache files, and records narrowly defined code signals. It never imports package code or extracts archives to executable locations. The optional offline mode consumes previously downloaded files and recorded HTTP statuses under `/private/tmp/yro-security-artifacts`.

The `evidence/` directory retains the dependency graph, registry responses, OSV query/response, GitHub advisory snapshots, engine-origin evidence, build manifest, and browser observations. Dates belong to this review; new material advisories or changed artifacts require reassessment.
