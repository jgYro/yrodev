# Tunings preview

- Source: https://tunings.io/
- Captured: 2026-10-28 with the available Playwright MCP browser, at 1200 × 800 pixels.
- Asset: `assets/previews/tunings.png`.
- Content: public homepage, with optional tracking declined and no signed-in account.
- Placement: Apps section within What We’ve Done, after the capabilities and Media chapter and before recognition.

The public site returned `X-Frame-Options: DENY` and Content Security Policy `frame-ancestors 'none'` when inspected. A live iframe cannot render under those policies. The section therefore serves a local screenshot in a browser-style frame; the preview and its link open the real website in a new tab with `noopener,noreferrer`. The label says “Website preview” rather than claiming it is live.

The app description is a high-level summary of the public homepage's music workbench, chord, tuning, fretboard, and teaching features. The owner requested that Tunings be presented as an app made by Yro.

The preview incorporates no third-party executable code, remote scripts, trackers, packages, or runtime dependencies. It is a bitmap asset. The screenshot can be refreshed after Tunings changes, using the same public-page capture workflow.
