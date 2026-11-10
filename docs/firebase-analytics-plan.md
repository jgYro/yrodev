# Yro Firebase Analytics

Updated 2026-11-02. The priority is business inquiries and contact intent. The web application now uses Google's managed Analytics tag through a small Dart/JavaScript bridge, with no added Dart or npm packages. The original website layout is unchanged; the only new interface is the analytics choice and footer settings control.

## Destination

| Setting | Value |
| --- | --- |
| Website | `https://yro.dev/` |
| Firebase project | `yro-llc` (Yro LLC) |
| Firebase Web App | `1:228228369868:web:468a1dfe8d6e32372a6169` — Yro website (yro.dev) |
| Analytics account | `334613485` |
| GA4 property | `561979164` |
| Web stream | `16258141419` |
| Measurement ID | `G-BWE0W2NDHG` |

[Open Analytics](https://analytics.google.com/analytics/web/#/p561979164/reports/intelligenthome) or [Firebase Analytics](https://console.firebase.google.com/project/yro-llc/analytics/overview). The owner enabled Analytics on the Firebase project; this integration registered the web app and used the resulting measurement ID.

## What is measured

| Event | Meaning | Parameters |
| --- | --- | --- |
| `page_view` | One page load after consent, including a returning consenting visit. | Sanitized page URL/title/referrer |
| `contact_click` | Each activation of a contact link, before handing off to email. | `placement`, `contact_context`, `method=email`, `active_chapter` |
| `chapter_view` | At least half of the smaller of chapter/viewport is visible for one second; once per chapter per page load. Backgrounding interrupts dwell. | `chapter_id` |
| `chapter_navigation` | Explicit chapter/menu or hero navigation. | `chapter_id`, `placement` |
| `portfolio_click` | Activation of a Tunings anchor, including keyboard activation. | `project_id=tunings`, `placement` |

Contact placements are `header`, `mobile_menu`, `working_with_yro`, `mind_country`, and `footer`. Context is `business` for Working with Yro, `community` for Mind Country, and `general` elsewhere. These identify the surrounding content, not a visitor's confirmed purpose. Chapter IDs are `who_we_are`, `what_we_do`, `what_weve_done`, and `why_we_do_it`; `hero` identifies contact before a chapter is active. Portfolio placements are `portfolio_text` and `portfolio_preview`.

**Contact clicks measure intent, not delivered email or qualified leads.** The site cannot know whether an email was sent. Do not label these events as completed inquiries or use `generate_lead` until a confirmed submission signal exists. Google's standard engagement/enhanced-measurement events may also appear; do not add them to contact counts.

## Collection controls

- The tag loads only after explicit consent, and only on HTTPS with the exact hostname `yro.dev`. No tag, analytics cookies, or queued historical activity before acceptance or after denial.
- A consent choice is stored locally for 180 days when storage is available. Expiration is checked on load and daily during a long-lived page. Footer **Analytics settings** allows withdrawal, clears the `yro_ga` cookies, and reloads to unload Google's runtime. Cross-tab choice changes reload other tabs.
- Advertising storage, advertising user data, and personalization consent remain denied; Google signals and ad personalization signals are disabled.
- Application events contain only allowlisted identifiers. No visitor identity, email, message, or arbitrary free text is explicitly supplied. Page location retains only bounded `utm_source`, `utm_medium`, and `utm_campaign` labels; arbitrary query fields, paths, and fragments are omitted. Referrer is reduced to origin. Keep personal information out of campaign labels.
- CSP allows the Google tag and specific Analytics collection origins. Analytics failure does not prevent contact or navigation. Google's standard managed behavior was accepted; remote enhanced-measurement settings were not edited.

Implementation: `web/analytics.js`, `lib/analytics*.dart`, contact/chapter hooks in `lib/site.dart`, and placement metadata on the existing native portfolio links. Other platforms use a no-op analytics implementation. The accepted managed-runtime exception and remaining uncertainty are recorded in [the dated supply-chain assessment](security/supply-chain/2026-11-02-google-tag/ASSESSMENT.md).

## Finish reporting setup in GA4

The available Firebase credentials can manage the Firebase web app and Hosting, but Analytics Admin API requests return 403 for insufficient scopes. The separate browser console session is signed out. These report settings therefore remain **unconfigured/unverified by this integration**:

1. In GA4 Admin → Data display → Events/Key events, mark or create `contact_click` as a key event. Label its reporting meaning **Contact intent**. Do not mark chapter/page events as business outcomes.
2. In Admin → Data display → Custom definitions, register event-scoped dimensions for `placement`, `contact_context`, `active_chapter`, `chapter_id`, and `project_id`. The event parameter and dimension scope must match exactly.
3. Verify the stream website URL is `https://yro.dev`, then review timezone, retention, user access, and internal/developer traffic filters. Start filters in testing mode before excluding traffic permanently.
4. Confirm events in Realtime/DebugView and later processed reports. Seeing an event in an HTTP request or receiving HTTP 204 does not prove it appears in a report. Custom dimensions can take 24–48 hours to become reportable.

See Google's [custom-dimension instructions](https://support.google.com/analytics/answer/14240153) and [DebugView guide](https://firebase.google.com/docs/analytics/debugview).

## Reading the reports

Review the last 28 complete days against the previous 28, showing counts alongside rates while traffic is small.

| Question | Report and interpretation |
| --- | --- |
| Which sources bring contact intent? | Traffic acquisition: session source/medium and campaign, sessions, and the session key-event rate specifically for `contact_click`. First-user acquisition answers a different question: where people were originally acquired. |
| How often do visits lead to contact? | Sessions containing at least one `contact_click` divided by measured sessions. Ten clicks in one session count as one contacting session. |
| Which contact placements get used? | An exploration filtered to `contact_click`, with `placement`/`contact_context`, event count, and users. Counts alone do not prove one placement is more effective because exposure differs. |
| What content precedes contact? | A path/funnel exploration from `page_view` through optional chapter engagement to contact. Allow direct header contact; do not require every chapter. Association is not causation. |
| Does mobile differ? | Compare contact-intent rate and counts by device category. Mobile contact is in the menu; desktop contact is in the header. |
| Are inquiries becoming work? | Track received and qualified inquiries separately; Analytics cannot infer this from `mailto:` activation. |

Consent choices, blockers, browsers, and devices affect measurement. Users are measured visitors, sessions are visits, and event count is actions; none provides an exact count of people. Use the [GA4 metric definitions](https://developers.google.com/analytics/devguides/reporting/data/v1/api-schema) when constructing reports.

Use consistent campaign links, for example `https://yro.dev/?utm_source=linkedin&utm_medium=social&utm_campaign=company_profile`. Do not campaign-tag internal navigation. Historical contact events cannot be reconstructed; comparisons start after collection is deployed.

## Domains

`yro.dev` has active ownership, Hosting, and TLS. Canonical and Open Graph metadata identify it as the public address. Analytics is disabled on both Firebase default hosts, localhost, and previews.

The two built-in addresses `yro-llc.web.app` and `yro-llc.firebaseapp.com` still serve the Hosting release. They are aliases of the default site, not removable custom-domain registrations. This integration does not claim to disable or redirect them. Firebase path-only redirects applied to this shared site can also match `yro.dev`, so a catch-all redirect would risk a loop. See [default Hosting sites](https://firebase.google.com/docs/hosting/default-site) and [redirect configuration](https://firebase.google.com/docs/hosting/full-config#configure_redirects).

## Verification on 2026-11-02

- `flutter analyze --no-pub`: passed.
- Six focused Analytics widget tests: passed. They cover denial, all desktop contact placements, narrow consent controls, failure isolation, chapter deduplication/dwell, and interruption by backgrounding.
- `flutter build web --no-pub --no-web-resources-cdn`: passed using the unchanged lockfile. JavaScript syntax and whitespace checks passed.
- Playwright MCP exercised the release bundle under the exact Hosting CSP: no requests/cookies before consent, one page view, mouse/keyboard contacts, portfolio keyboard activation, chapter dwell, persisted choice, withdrawal, blocked-tag behavior, and no collection on default/local/preview hosts.
- A real Google runtime check produced `page_view`, `contact_click` with `placement=mobile_menu`, `chapter_navigation`, and `chapter_view`, all addressed to `G-BWE0W2NDHG` with sanitized page fields. Collection was intercepted in this isolated check to avoid adding synthetic contacts to reports. Only the expected Google tag script and Analytics collection origin were observed, with no JavaScript errors or CSP violations. Both real `yro_ga` cookies were removed on withdrawal through the footer settings UI.
- Four existing full-suite layout tests also fail on an unchanged `HEAD` checkout: widths 320, 390, 1024, and the mobile-menu test. The original header and preview layout were preserved at the owner's request. These are pre-existing test failures, not a passing full suite.

Local browser scripts/screenshots remain under ignored `.playwright-mcp/`; the original-baseline and focused test logs are in `/private/tmp/yro-*-tests.log`. Live-release evidence is recorded in [Firebase deployment notes](firebase-deployment.md).
