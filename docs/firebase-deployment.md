# Firebase Hosting deployment

## Current release: app-emblem favicon

On 2026-11-10, source commit `dd73ac3` was deployed as Hosting version `projects/228228369868/sites/yro-llc/versions/9de89862bd7298db` to [yro.dev](https://yro.dev/). The favicon now uses the app's white split Y inside its blood-red circle, with the complete circuit emblem at larger sizes and an enlarged central mark at tab sizes. The HTML and manifest both reference `favicon.svg?v=20261110` so browsers can distinguish the replacement from cached icons.

The release build and Playwright MCP checks passed. Live page/icon responses returned HTTP 200; the SVG SHA-256 matches the source and build (`e823af3716df0b3107c98fcc88653b842c352357f9afc710359ed1686f325787`), and the live manifest matches the build. No page errors, failed requests, or external requests were observed during the unconsented live check. The update adds no dependencies and leaves Dart application code unchanged. See [validation.md](validation.md).

## 2026-11-09 release: black, white, blood red, purple, and IBM Plex

On 2026-11-09, the visual refresh was deployed as Hosting version `projects/228228369868/sites/yro-llc/versions/f89fed723c5b9267` to [yro.dev](https://yro.dev/). The design uses flat near-black surfaces, white type, dark blood-red action surfaces, purple graphic accents, square controls, and a matching favicon/loading state. IBM Plex Sans is used for main typography and IBM Plex Mono for navigation/labels. Four unmodified font files are self-hosted under their OFL license after the [pinned-font assessment](security/supply-chain/2026-11-09-ibm-plex/ASSESSMENT.md); Pub dependency versions remain unchanged.

Analysis, the release build, and all 13 existing widget tests passed. Tests now load the actual bundled fonts instead of Ahem; the narrow-width failures from the earlier baseline no longer occur with the real typography. A local Flutter hot restart completed successfully. Playwright MCP checked 320, 390, 1024, and 1440-pixel views, all chapter navigation, consent controls, and the existing analytics regression scenarios. Main text/button color pairs have contrast ratios of at least 7.78:1 in their default states. Screenshots were visually inspected on desktop and mobile.

The live HTML, application JavaScript, favicon, and all four fonts match local SHA-256 values. Initial requests remain same-origin with no Analytics cookies before consent. No JavaScript errors or failed requests were observed. The evidence is in [yro-plex-verification.json](yro-plex-verification.json), with screenshots under ignored `.playwright-mcp/plex-*.png`. Content, contact destinations, event names, and the production-only collection rule are preserved.

## 2026-11-02 release: Analytics on yro.dev

On 2026-11-02, Analytics was deployed as Hosting version `projects/228228369868/sites/yro-llc/versions/9cfeb2e4f2f74875`. The production address is [yro.dev](https://yro.dev/), with matching canonical metadata. Google tag `G-BWE0W2NDHG` measures opted-in visits, contact intent, chapter engagement, and portfolio interest only on that hostname. The original website layout is preserved; the analytics choice and footer settings are the new interface controls. No Dart/npm package versions changed. The managed Google runtime is covered by the [accepted exception](security/supply-chain/2026-11-02-google-tag/ASSESSMENT.md).

The live page returned 200 with the expected CSP, zero external requests/cookies before consent, and a `page_view` collection response of HTTP 204 after acceptance. Live `analytics.js` and `main.dart.js` SHA-256 hashes match the tested local build. No JavaScript errors were observed. Transport success is not confirmation of processed Analytics reports. Details are in [firebase-analytics-verification.json](firebase-analytics-verification.json) and the [reporting guide](firebase-analytics-plan.md).

Static analysis, all six focused Analytics widget tests, the release build, and Playwright MCP consent/event checks passed. Four existing layout tests fail identically in an unchanged `HEAD` checkout; their unrelated layout changes were reverted. The entire test suite is therefore not reported as passing. The two built-in Firebase host aliases still serve the release, but cannot initialize Analytics.

## 2026-10-28 release: broader introduction

On 2026-10-28, the broader introduction was deployed as Hosting version `projects/228228369868/sites/yro-llc/versions/28131afa2ef9ed31`. It presents software, security, applied AI, and creative media, with matching metadata. Dart analysis, the release build, and desktop/mobile Playwright checks passed. The live HTML matches the rebuilt artifact, and the rendered live hero was verified after deployment. No package versions or Hosting security settings changed.

## Initial release record

Deployed and verified on 2026-10-28.

- Live site: [https://yro-llc.web.app](https://yro-llc.web.app).
- Firebase project and Hosting site: `yro-llc` (display name: Yro LLC).
- [Firebase Hosting console](https://console.firebase.google.com/project/yro-llc/hosting).
- Hosting version: `projects/228228369868/sites/yro-llc/versions/3f20008516debd83`.
- Reviewed application checkpoint: `d5a5c8c6bc8c171676c3a32494c38c6320ccd16f`.

## Release contents

The existing reviewed release artifact was deployed without rebuilding or changing application code. All 43 local build files matched the security review's SHA-256 manifest. Firebase publishes 36 files totaling 33,324,982 uncompressed bytes after excluding the hidden build ID and renderer symbol files. Only `build/web` is public. Application source, internal documentation, Firebase configuration, and the checkpoint repository are outside that directory.

`firebase.json` explicitly targets the `yro-llc` site. `.firebaserc` selects the corresponding project. Unknown paths return 404 because this single-page business overview does not implement URL-based routes. Chapter navigation is handled within the page.

The deployment applies CSP, frame protection, MIME sniffing protection, a no-referrer policy, and camera/microphone/geolocation restrictions. All filenames are served with cache revalidation because Flutter's generated filenames are not content-addressed. Firebase's default domain also supplies HTTPS redirection and HSTS. See [Firebase Hosting configuration](https://firebase.google.com/docs/hosting/full-config) and [cache behavior](https://firebase.google.com/docs/hosting/manage-cache).

## Verification

- Firebase deployment job completed successfully.
- The public root returned HTTP 200 over HTTPS; HTTP redirected to HTTPS with 301.
- The live HTML, main JavaScript bundle, and Chromium CanvasKit WASM bytes matched the local release artifacts.
- JavaScript was served as `text/javascript`; WASM as `application/wasm`.
- The actual response contained the configured CSP, `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: no-referrer`, permissions policy, and cache policy. HSTS was present.
- Playwright MCP exercised all four desktop chapter controls and all four mobile menu destinations at 390 pixels. The menu closed after navigation. Desktop and mobile screenshots were visually inspected.
- No browser console errors, page errors, or failed requests were observed. Initial loading fetched only same-origin resources. Both portfolio anchors retained their fixed HTTPS destination and `noopener noreferrer` attributes.
- `/.firebaserc`, `/firebase.json`, `/source/pubspec.yaml`, `/docs/security/review-2026-10-28/REPORT.md`, and `/canvaskit/canvaskit.js.symbols` returned 404.

Observations are saved in [firebase-deployment-verification.json](firebase-deployment-verification.json). Visual checks are in [firebase-live-desktop.png](firebase-live-desktop.png) and [firebase-live-mobile.png](firebase-live-mobile.png).

The prior security report remains an accurate record of its pre-deployment checkpoint. Its YRO-02 header gap has now been addressed and checked for this Firebase origin. Its native-platform findings and broader supply-chain limitations remain applicable to their stated scopes.

## Dependency and deployment scope

This release changes the static hosting provider and response configuration. It introduces no Firebase client SDK, server runtime, npm dependency, container, or native binary. The existing JavaScript, WebAssembly, and font artifacts are unchanged. The Firebase MCP integration is deployment tooling, not a program dependency. No new application dependency was installed or executed, and no changed dependency graph required assessment. The previous dependency review remains in `docs/security/review-2026-10-28`.

## Future releases

From the authoritative project root, use the approved installed SDK and existing lockfile:

```sh
flutter build web --no-pub --no-web-resources-cdn
firebase deploy --only hosting --project yro-llc
```

Alternatively, use the existing Firebase MCP deployment tool after selecting this directory and project. This release used MCP; the installed standalone Firebase executable failed during its version check and was not used to publish.

After deployment, verify the live page, chapter navigation, headers, and critical asset responses. Preserve the source checkpoint and updated deployment notes. Keep Firebase debug logs and `.firebase/` cache files out of version control. For rollback, select a previous successful release in the Firebase Hosting console; this is the project's first release.
