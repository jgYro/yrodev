# Yro site checkpoint

## Current implementation

- Responsive Flutter business overview with dark teal and charcoal colors, circuit artwork, and subtle sacred geometry.
- The introduction now gives software, security, AI, and creative media a broader shared focus. The headline is “Software, security, and creative work.”
- Who We Are groups experience in government and cleared environments with the approach to requirements, early prototypes, frequent feedback, and practical technology choices.
- What We Do groups Cyber, R&D, AI, and Media capabilities.
- What We’ve Done showcases Tunings with a captured website preview and records the owner's stated individual acceptance into Anthropic CVP and OpenAI Daybreak. Recognition stays near the bottom of the page. The Tunings source site blocks embedding, so its preview is a local screenshot linked to the live site.
- Why We Do It contains Mind Country, Appalachian roots, and invitations for volunteering, speaking, education, and community opportunities.
- The four chapters use large headings, distinct background tones, fixed navigation with an active indicator, and a reading-progress line. Entrance and navigation motion respect reduced-motion preferences.
- All public contact uses business@yro.dev. Public copy omits the owner's name and em dashes.

## Recognition sources

The owner supplied the individual acceptance claim in this conversation. Public sources confirm program names and general purpose, not this individual's enrollment. No access tier, date of admission, certification, partnership, or company endorsement is asserted.

- [Anthropic: Expanding the Cyber Verification Program](https://www.anthropic.com/news/cyber-verification-program), checked 2026-10-27.
- [OpenAI: Troubleshooting OpenAI Daybreak](https://help.openai.com/en/articles/20001259-troubleshooting-openai-daybreak), checked 2026-10-27. The official guidance distinguishes individual and organization access.

## Files and publication

The project root is the authoritative source. Creating a root `.git` directory is blocked by this environment, so its checkpoint is saved in the existing repository at `.site/yro-overview`. That repository's `source/` directory contains the complete source snapshot, platform scaffolding, lockfile, tests, documentation, and selected preview images. Tool caches and browser logs remain ignored.

The website is live at [yro-llc.web.app](https://yro-llc.web.app) on Firebase Hosting project `yro-llc`, deployed and verified on 2026-10-28. The root `firebase.json` and `.firebaserc` define that deployment. See [firebase-deployment.md](firebase-deployment.md) for release details and checks. The older Sites registration and prepared web output remain preserved in `.site/yro-overview`; they are separate from the current Firebase deployment.

## Validation and remaining work

See `validation.md` for completed analysis, build, and Playwright checks, and `firebase-deployment.md` for verification against the live host. Widget tests have not run successfully because the environment denies the test runner's loopback socket. Native clipboard behavior has not been tested. Run the existing widget suite in an unrestricted local development environment.

No new program dependencies were introduced.

## Root Git setup

The requested GitHub repository is `https://github.com/jgYro/yrodev.git`, with `master` as its primary branch. GitHub's public API confirmed it was empty during setup. Root initialization remains pending: this environment denied creation of `.git`, and the available GitHub credentials failed authentication. `scripts/setup-git.sh` contains the complete owner-run initialization and first-commit procedure. Flutter/Firebase ignore rules, line-ending defaults, the SDK version file, and a check script are prepared. See `git-workflow.md`. The historical checkpoint repository is preserved separately.
