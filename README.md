# Yro LLC

A responsive Flutter website for software, cybersecurity, applied AI, and creative media, organized into four chapters: Who We Are, What We Do, What We’ve Done, and Why We Do It. Large chapter headings, distinct dark backgrounds, fixed chapter navigation, a reading-progress line, and subtle entrance effects give the page a clear scrolling sequence. The charcoal, teal, and fine circuit artwork follow the supplied business card, with restrained sacred geometry in the original vector illustrations.

## Repository workflow

The requested repository is [jgYro/yrodev](https://github.com/jgYro/yrodev), using `master`. Root initialization is pending because the agent environment protects `.git`. Run `sh scripts/setup-git.sh` from your own terminal to initialize the repository, configure the remote and business commit identity, and create the first commit. GitHub authentication is required for the first push. See [docs/git-workflow.md](docs/git-workflow.md) for exact commands and release steps.

The project includes Flutter/Firebase ignore rules, `.gitattributes`, `.editorconfig`, and a pinned `.flutter-version`. Use `sh scripts/check.sh` with that SDK and the existing locked dependencies for analysis, tests, and the release build.

## Run and build

Use the existing Flutter SDK and the checked-in `pubspec.lock`:

```sh
flutter run -d web-server --web-port 8080 --no-pub
flutter test --no-pub
flutter build web --no-pub --no-web-resources-cdn
```

The web build is in `build/web`. Serve this directory with a static web host. The custom bootstrap loads the CanvasKit renderer from the same origin.

## Content and layout

- `lib/site.dart`: page copy, section navigation, responsive layout, and reusable UI.
- `lib/visuals.dart`: original circuit, Media, and Appalachian ridge illustrations.
- `lib/contact.dart`: the public business contact and platform dispatch. Web links open a mail draft; native builds copy the address and show a confirmation.
- `lib/external_link.dart`: accessible website links that open a separate browser tab, with a clipboard fallback on native platforms.
- `assets/previews/tunings.png`: a public Tunings website screenshot captured with Playwright on 2026-10-28.
- `lib/main.dart`: application and theme.
- `web/`: metadata, loading state, favicon, and web bootstrap.
- `test/widget_test.dart`: responsive layout and desktop/mobile navigation checks.

Who We Are contains the experience and Working with Yro sections. What We Do groups Cyber, R&D, AI, and Media. What We’ve Done contains Tunings and individual program recognition. Why We Do It holds Mind Country and the Appalachian community invitation. Chapter headings reveal once as they enter view; reduced-motion preferences remove those transitions and use immediate navigation. Scrolling remains under the visitor's control.

Capability descriptions reflect recurring themes in the owner's project portfolio: security automation and assurance, applied research and software engineering, and practical AI for knowledge, workflows, and decision support. The About section describes experience in government and cleared environments across operational, engineering, research, and technical leadership roles. It does not name an individual or claim a company facility clearance. Media reflects the owner’s stated creative capabilities and more than 15 years of audio engineering, alongside sound design, video editing, 3D modeling, and marketing and commercial content. Employer engagements and internal projects are not presented as Yro clients or products; no private project details or résumé contact information are published. Working with Yro describes business-to-technical communication, early workflow and feasibility demonstrations, frequent feedback, rapid iteration, and simple solutions selected for the customer. Mind Country is an invitation to volunteer, speak, and support Appalachian communities, not a claim of nonprofit status. All public contact uses `business@yro.dev`. No CMS, analytics, forms, or third-party embeds are included.

The recognition section records the owner's stated individual acceptance into Anthropic's Cyber Verification Program (CVP) and OpenAI's Daybreak program. It uses the official program names without identifying a tier or claiming company membership, certification, partnership, or endorsement. Program references and the current checkpoint are in `docs/project-status.md`.

Apps showcases Tunings with a browser-style screenshot and links to `https://tunings.io/`. The site returns `X-Frame-Options: DENY` and CSP `frame-ancestors 'none'`, so the preview is a locally served image, not a live iframe. No remote scripts or tracking are loaded by the preview. Recognition remains near the bottom, after Apps in What We’ve Done and before the Appalachian chapter.

## Dependency scope

This implementation keeps the existing dependency versions and lockfile. It uses Dart and the Flutter SDK already configured for this project. No new package or runtime was introduced by the copy, Firebase, or Git workflow changes. The dated dependency research and its coverage limits are recorded in [docs/security/review-2026-10-28/REPORT.md](docs/security/review-2026-10-28/REPORT.md).

## Review and publishing

Current chapter screenshots are saved in `docs/preview-who-we-are.png`, `docs/preview-what-we-do.png`, `docs/preview-what-weve-done.png`, `docs/preview-why-we-do-it.png`, and the corresponding mobile previews. `docs/preview-desktop.png` and `docs/preview-mobile.png` show the hero. Earlier section previews remain as historical references. Validation details and environmental limits are in `docs/validation.md`.

The live site is [yro-llc.web.app](https://yro-llc.web.app), deployed to Firebase Hosting project `yro-llc`. `firebase.json` publishes only `build/web`, applies the verified browser security policy, and excludes debug symbols, source maps, and hidden files. Deployment details and repeatable commands are in [docs/firebase-deployment.md](docs/firebase-deployment.md).

A private Sites registration and the existing Git repository are preserved under `.site/yro-overview`. The repository holds the complete source snapshot under `source/` and the prepared web build under `dist/`. Creating Git metadata at the project root is blocked by the environment. The Flutter source at the project root remains authoritative. The earlier Sites publication attempt was unsuccessful; the current live deployment uses Firebase.
