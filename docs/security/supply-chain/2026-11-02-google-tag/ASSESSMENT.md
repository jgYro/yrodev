# Google Analytics tag assessment

Date: 2026-11-02. Intended scope: the public Flutter website at `https://yro.dev`, using Firebase project `yro-llc`, GA4 property `561979164`, web stream `16258141419`, and measurement ID `G-BWE0W2NDHG`.

**Decision: BLOCKED under the default policy; authorized for this integration by explicit user exception on 2026-11-02.** The managed Google tag does not provide an immutable runtime version, a complete independently resolvable bundled/deferred dependency graph, or verified release provenance. Current advisory coverage is incomplete. The user accepted the scoped Google-tag exception and then clarified, “we can use whatever google uses.” This permits the standard Google Analytics managed runtime and updates for this site and stream. It is not an unconditional supply-chain PASS or approval for unrelated dependencies. The candidate was not executed before acceptance.

## Inventory and minimization

| Component | Exact identity or observed artifact | Relationship and purpose |
| --- | --- | --- |
| Google tag JavaScript | `https://www.googletagmanager.com/gtag/js?id=G-BWE0W2NDHG`; downloaded 2026-11-02 22:10:04 UTC; 473602 bytes; SHA-256 `95903419271b41fe18f2b428165c2211209b53e614397115a1148fe9ac90d909` | Proposed direct browser dependency, loaded only after analytics consent on `yro.dev`; delivers events to the existing Firebase-linked GA4 stream. The URL is mutable, not an immutable version. |
| Embedded Google tag runtime and templates | Bundled inside the above hash; internal configuration says resource version `1`, which is not a library release pin. Individual component identities/source revisions are not published in a usable manifest. | Cookie/session management, event collection, consent, network transport, automatic detection, destination configuration. Complete embedded inventory unresolved. |
| Deferred destination/runtime scripts | Static code contains `/gtag/destination`, script creation, and service-worker capability references. Exact future artifacts cannot be enumerated from a stable manifest. | Potential runtime dependencies controlled by Google and tag configuration. Their complete versions, hashes, and provenance are unresolved; no second-stage code was loaded. |
| Firebase client SDK / FlutterFire / npm wrappers | None proposed for installation. | A direct first-party Dart-to-JavaScript bridge can use the Google tag without adding these packages. Adding FlutterFire would expand the graph without removing the web runtime issue. |
| Existing Flutter/Dart/browser environment | Existing Flutter 3.47.8 / Dart 3.13.7 web build, with unchanged `pubspec.lock` and deployment runtime. | No version or deployment-target change. Native Android/iOS/macOS releases are outside this integration. Prior assessments remain in `docs/security/review-2026-10-28`. |

No standard-library implementation provides Google's supported browser Analytics runtime. A custom implementation of an undocumented collection protocol is not an adequate replacement. Measurement Protocol requires a server-side design and secret handling; exposing its secret in this static site is not acceptable. A fixed self-hosted snapshot would still require verification of bundled and dynamically loaded components and changes Google's supported update model.

## Identity and integrity

Google's [official installation documentation](https://developers.google.com/tag-platform/gtagjs) specifies `www.googletagmanager.com/gtag/js?id=TAG_ID`. The requested ID came from Firebase's SDK configuration for app `1:228228369868:web:468a1dfe8d6e32372a6169`, created for this task. No similarly named npm package or unofficial mirror was used.

The download used HTTPS certificate verification with curl and returned HTTP 200, `application/javascript`, `server: Google Tag Manager`, and `cache-control: private, max-age=900`. SHA-256 and SHA-384 are recorded in `static-inspection.json`. The downloaded file remains inert at `/private/tmp/yro-analytics-review-2026-11-02/gtag.js`.

These hashes identify the inspected bytes only. They do not pin later browser responses. No independently authenticated release checksum, source commit, build workflow, signature, attestation, or reproducible-build evidence was found or cryptographically verified. The closed, managed service does not expose normal package publisher/repository and ownership history. Official documentation plus authenticated HTTPS is origin evidence, not proof of benign behavior or release provenance.

## Current security intelligence

- Reviewed Google's [tag release notes](https://support.google.com/tagmanager/answer/4620708?hl=en), including 2026-10-08 behavior changes and the 2026-07-09 distinction between product tag IDs and GTM container IDs. The integration proposes a `G-` product tag, not a custom GTM container.
- Queried Google documentation/security-result searches and independent OSV, GitHub Advisory Database, and NVD searches for `gtag.js` / Google tag. No confirmed advisory was mapped to this exact downloaded artifact. This is **not** a complete or clean vulnerability scan: OSV's listing failed to load, the GitHub search included an error/loading state, and there is no immutable package coordinate with which to match all bundled code. A package-manager audit does not cover this managed artifact.
- NVD surfaced [CVE-2025-23537](https://nvd.nist.gov/vuln/detail/CVE-2025-23537), a high-severity CSRF-to-stored-XSS issue in the WordPress **add custom google tag manager** plugin through 1.0.3. That plugin, WordPress, and its vulnerable admin workflow are absent; this finding is not a match for Google's hosted tag. No fixed version is needed for this project because the affected component is not used.
- Compromise/malware searches did not establish a malicious release of the proposed artifact. They do not establish that the artifact or future responses are malware-free. Misuse of Analytics endpoints for exfiltration and unrelated sites' unpinned-tag findings must not be described as a confirmed Google compromise.

Reproduction sources: [OSV query](https://osv.dev/list?q=gtag.js), [GitHub query](https://github.com/advisories?query=gtag.js), [Google installation](https://developers.google.com/tag-platform/gtagjs), [Google privacy controls](https://developers.google.com/tag-platform/security/guides/privacy), [Google consent](https://developers.google.com/tag-platform/security/guides/consent).

## Static execution review

The candidate was downloaded and read as text only. Static searches and targeted code/configuration inspection found cookie/local-storage access, script creation, beacon/fetch/XHR networking, DOM/form/user-data detection, and destination loading. These are consistent with a general-purpose measurement runtime, but the entire minified bundle was not reverse-engineered and this is not an exhaustive malware review. No install/build hooks, native executables, or package preparation steps are used by the proposed direct-script integration.

The response contains capability/configuration entries for outbound clicks, scrolling, downloads, history, forms, video, and user-provided-data detection. Merely configuring custom contact events would not turn these off. The candidate also contains Google advertising, YouTube, and service-worker code paths that are outside the intended feature scope; their presence does not prove those paths execute. Default denied advertising consent, disabled Google signals/ad personalization, restricted CSP, and remote collection settings are required scope controls.

Firebase CLI authentication succeeded for Firebase Management but the Analytics Admin property/stream reads returned HTTP 403 for insufficient OAuth scopes. Remote Analytics settings cannot currently be edited through those credentials. The browser console session is separately signed out. The user subsequently authorized Google's standard setup; normal enhanced-measurement events may therefore accompany explicit application events. Advertising/user-data consent remains denied, and the application supplies no visitor identity or user-provided fields. Changing the site's data inputs or adding forms requires revisiting automatic collection.

## Proposed exception

Allow Google's managed tag for **this public website and this one GA4 destination**, accepting the lack of immutable versioning, complete bundled/deferred component inventory, exact-version advisory coverage, and verified source/build provenance. This is an exception for a managed runtime, not a claim of supply-chain PASS and not approval for arbitrary new packages, ads, custom GTM tags, other destinations, native SDKs, or self-hosted copies.

Controls implemented and verified (see verification record below):

- Load only after a visitor explicitly accepts analytics; send no pre-consent history and offer withdrawal.
- Collect only on the exact production hostname `yro.dev`; no collection on localhost, previews, or Firebase default hosts.
- Disable advertising/user-data consent, Google signals, and personalization in application configuration; use explicit, bounded contact/chapter events. Google's normal automatic measurements may also occur under the user's clarified scope. Remote automatic-detection settings were not modified.
- Use narrowly allowed HTTPS script/collection origins in CSP. Preserve the existing frame, object, and general script restrictions.
- Never send visitor email, message text, user IDs, or arbitrary query/referrer values. Keep the site usable when the tag fails or is blocked.
- Test local authored code using a synthetic tag stub before any Google runtime is executed. After acceptance, inspect real requests and reject unexpected executable origins/artifacts rather than silently expanding the exception.
- Reassess new feature scope, domains/destinations, material security evidence, or unexpected changes in runtime behavior. Mutable managed releases are the specific ongoing risk requiring acceptance.

**User acceptance:** “Accept this scoped Google-tag exception,” followed by “we can use whatever google uses,” on 2026-11-02 before runtime incorporation or execution. The latter clarification permits Google's standard managed Analytics behavior without requiring manual removal of every enhanced-measurement default. This does not authorize Google Ads integration, explicit visitor identity collection, or unrelated packages.

Inspection tools: system curl for passive HTTPS retrieval, Python standard-library hashing/text inspection, web research, Firebase MCP, and the existing Firebase CLI 15.34.2 for project metadata. Node 24.16.0 and npm 11.13.0 were observed for task tooling; npm is not used to add an application dependency. The existing application runtime/lockfile is unchanged.

## Post-acceptance verification

On 2026-11-02, after the recorded exception, the authored bridge passed isolated Playwright MCP checks with a synthetic tag. Google's managed runtime was then executed in an isolated browser using the release bundle and exact Hosting CSP. Observed external requests were limited to `www.googletagmanager.com/gtag/js` and `www.google-analytics.com/g/collect`; no deferred executable request was observed in this session. Collection was intercepted to avoid sending synthetic contact events to production. Page, mobile-menu contact, navigation, and dwell events had the expected stream/parameters, sanitized page fields, and denied advertising consent. No CSP violations or JavaScript errors occurred. Withdrawal removed both `yro_ga` cookies and unloaded the tag.

The verified release was deployed to `yro.dev`; live pre-consent requests remained same-origin, the two main application script hashes matched the local build, and Google returned HTTP 204 for a live verification page view. See [live verification](../../../firebase-analytics-verification.json). These observations are bounded runtime checks, not a complete dependency inventory or proof about future managed updates; the explicit exception remains the basis for use.
