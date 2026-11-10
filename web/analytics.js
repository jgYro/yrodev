// Google-managed runtime exception and scope:
// docs/security/supply-chain/2026-11-02-google-tag/ASSESSMENT.md
(() => {
  'use strict';
  const measurementId = 'G-BWE0W2NDHG';
  const consentKey = 'yro.analytics-consent.v1';
  const consentLifetime = 180 * 24 * 60 * 60 * 1000;
  const supported = location.protocol === 'https:' && location.hostname === 'yro.dev';
  const disableKey = `ga-disable-${measurementId}`;
  const chapters = ['who_we_are', 'what_we_do', 'what_weve_done', 'why_we_do_it'];
  const contactPlacements = ['header', 'mobile_menu', 'working_with_yro', 'mind_country', 'footer'];
  let choice = readChoice();
  let initialized = false;
  let loadingFailed = false;
  let expiryTimer;

  function readChoice() {
    if (!supported) return 'unknown';
    try {
      const stored = JSON.parse(localStorage.getItem(consentKey));
      if (stored && stored.expiresAt > Date.now() &&
          ['granted', 'denied'].includes(stored.choice)) return stored.choice;
    } catch (_) { /* Storage can be unavailable; default to no collection. */ }
    return 'unknown';
  }

  function remember(value) {
    try {
      localStorage.setItem(consentKey, JSON.stringify({
        choice: value, expiresAt: Date.now() + consentLifetime,
      }));
    } catch (_) { /* The choice still applies to this page in memory. */ }
  }

  function clearAnalyticsCookies() {
    for (const entry of document.cookie.split(';')) {
      const name = entry.split('=')[0].trim();
      if (!/^yro_ga(?:_|$)/.test(name)) continue;
      for (const domain of ['', '; Domain=yro.dev', '; Domain=.yro.dev']) {
        document.cookie = `${name}=; Max-Age=0; Path=/; SameSite=Lax; Secure${domain}`;
      }
    }
  }

  function pageFields() {
    // Keep only bounded campaign labels, never arbitrary query/referrer values.
    const safeLocation = new URL('https://yro.dev/');
    const input = new URLSearchParams(location.search);
    for (const name of ['utm_source', 'utm_medium', 'utm_campaign']) {
      const value = input.get(name);
      if (value && /^[a-zA-Z0-9_.-]{1,80}$/.test(value)) safeLocation.searchParams.set(name, value);
    }
    let referrer = '';
    try {
      const url = new URL(document.referrer);
      if (['http:', 'https:'].includes(url.protocol)) referrer = `${url.origin}/`;
    } catch (_) { /* Empty or invalid referrer. */ }
    return {page_location: safeLocation.href, page_referrer: referrer,
      page_title: 'Yro LLC | Software, Security, AI & Media'};
  }

  function initialize() {
    if (!supported || choice !== 'granted' || initialized) return;
    initialized = true;
    window[disableKey] = false;
    window.dataLayer = window.dataLayer || [];
    window.gtag = function () { window.dataLayer.push(arguments); };
    window.gtag('consent', 'default', {
      analytics_storage: 'denied', ad_storage: 'denied',
      ad_user_data: 'denied', ad_personalization: 'denied',
    });
    window.gtag('consent', 'update', {analytics_storage: 'granted'});
    window.gtag('js', new Date());
    window.gtag('set', {
      ...pageFields(), allow_google_signals: false,
      allow_ad_personalization_signals: false,
    });
    window.gtag('config', measurementId, {
      ...pageFields(), send_page_view: false,
      allow_google_signals: false, allow_ad_personalization_signals: false,
      cookie_prefix: 'yro', cookie_domain: 'yro.dev', cookie_path: '/',
      cookie_flags: 'SameSite=Lax;Secure', cookie_expires: consentLifetime / 1000,
    });
    window.gtag('event', 'page_view', {...pageFields(), send_to: measurementId});
    const script = document.createElement('script');
    script.async = true;
    script.src = `https://www.googletagmanager.com/gtag/js?id=${measurementId}`;
    script.onerror = () => {
      loadingFailed = true;
      window[disableKey] = true;
      window.dataLayer.length = 0;
    };
    document.head.appendChild(script);
    expiryTimer = window.setTimeout(checkExpiry, 24 * 60 * 60 * 1000);
  }

  function checkExpiry() {
    try {
      const stored = JSON.parse(localStorage.getItem(consentKey));
      if (stored && (stored.choice !== 'granted' || stored.expiresAt <= Date.now())) {
        window[disableKey] = true;
        clearAnalyticsCookies();
        location.reload();
        return;
      }
    } catch (_) { /* The current page can retain its in-memory choice. */ }
    expiryTimer = window.setTimeout(checkExpiry, 24 * 60 * 60 * 1000);
  }

  function setConsent(granted) {
    if (!supported) return;
    const wasInitialized = initialized;
    choice = granted ? 'granted' : 'denied';
    remember(choice);
    if (granted) {
      initialize();
    } else {
      window[disableKey] = true;
      clearTimeout(expiryTimer);
      clearAnalyticsCookies();
      // Unload Google's listeners/timers and discard any queued events.
      if (wasInitialized) location.reload();
    }
  }

  function validatedParameters(event, parameters) {
    if (!parameters || typeof parameters !== 'object' || Array.isArray(parameters)) return null;
    if (event === 'contact_click') {
      const placement = parameters.placement;
      if (!contactPlacements.includes(placement) ||
          !['hero', ...chapters].includes(parameters.active_chapter)) return null;
      return {placement, method: 'email', active_chapter: parameters.active_chapter,
        contact_context: placement === 'mind_country' ? 'community' :
          placement === 'working_with_yro' ? 'business' : 'general'};
    }
    if (event === 'chapter_view' && chapters.includes(parameters.chapter_id)) {
      return {chapter_id: parameters.chapter_id};
    }
    if (event === 'chapter_navigation' && chapters.includes(parameters.chapter_id) &&
        ['header', 'mobile_menu', 'hero', 'chapter_navigation'].includes(parameters.placement)) {
      return {chapter_id: parameters.chapter_id, placement: parameters.placement};
    }
    if (event === 'portfolio_click' &&
        ['portfolio_text', 'portfolio_preview'].includes(parameters.placement)) {
      return {project_id: 'tunings', placement: parameters.placement};
    }
    return null;
  }

  function track(event, json) {
    if (!supported || choice !== 'granted' || !initialized || loadingFailed ||
        document.visibilityState !== 'visible') return false;
    try {
      const parameters = validatedParameters(event, JSON.parse(json));
      if (!parameters) return false;
      // Bound the queue if a tag request hangs. Never retain unlimited actions.
      if (window.dataLayer.length > 500) return false;
      window.gtag('event', event, {...parameters, ...pageFields(), send_to: measurementId});
      return true;
    } catch (_) { return false; }
  }

  window.yroAnalytics = Object.freeze({available: () => supported,
    consent: () => choice, setConsent, track});
  window[disableKey] = choice !== 'granted' || !supported;
  if (supported) {
    if (choice !== 'granted') clearAnalyticsCookies();
    document.addEventListener('click', event => {
      const link = event.composedPath().find(node =>
        node instanceof HTMLAnchorElement && node.classList.contains('yro-external-link'));
      if (!link || link.href !== 'https://tunings.io/') return;
      track('portfolio_click', JSON.stringify({placement: link.dataset.analyticsPlacement}));
    }, true);
    window.addEventListener('storage', event => {
      if (event.key === consentKey || event.key === null) {
        window[disableKey] = true;
        location.reload();
      }
    });
    initialize();
  }
})();
