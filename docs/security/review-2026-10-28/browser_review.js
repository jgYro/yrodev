// Run with the existing Playwright MCP browser_run_code_unsafe tool.
// Serves committed build bytes in an isolated context. No production claims.
async (page) => {
  const root = '/Users/jerichogregory/Yro/projects/yro/build/web';
  const browser = page.context().browser();
  for (const old of browser.contexts()) {
    if (old !== page.context() && old.pages().some(p => p.url().startsWith('https://yro.audit.invalid/'))) await old.close();
  }
  const context = await browser.newContext({viewport: {width:1440,height:1050}, reducedMotion:'reduce'});
  const result = {testedAt:new Date().toISOString(),browserVersion:browser.version(),origin:'https://yro.audit.invalid',productionHostTested:false,requests:[],pageErrors:[],failedRequests:[]};
  let responseHeaders = {};
  await context.route('https://yro.audit.invalid/**', async route => {
    const path = decodeURIComponent(new URL(route.request().url()).pathname);
    if (path.includes('..')) return route.abort();
    try { await route.fulfill({path:root+(path==='/'?'/index.html':path),headers:responseHeaders}); }
    catch { await route.fulfill({status:404,body:'Not found'}); }
  });
  const p = await context.newPage();
  p.on('request', r => result.requests.push({url:r.url(),method:r.method(),type:r.resourceType()}));
  p.on('pageerror', e => result.pageErrors.push(e.message));
  p.on('requestfailed', r => result.failedRequests.push({url:r.url(),error:r.failure()?.errorText}));
  const enable = async target => {
    await target.getByRole('button',{name:'Enable accessibility'}).dispatchEvent('click');
    await target.getByRole('button',{name:'Who We Are',exact:true}).waitFor({timeout:10000});
  };
  try {
    await p.goto('https://yro.audit.invalid/',{waitUntil:'networkidle'});
    await enable(p);
    for(const label of ['Who We Are','What We Do','What We’ve Done','Why We Do It']) await p.getByRole('button',{name:label,exact:true}).click();
    result.baseline = await p.evaluate(async () => ({
      cookies:document.cookie,localStorage:Object.keys(localStorage),sessionStorage:Object.keys(sessionStorage),
      indexedDB:await indexedDB.databases(),caches:await caches.keys(),serviceWorkers:(await navigator.serviceWorker.getRegistrations()).map(x=>x.scope),
      anchors:[...document.querySelectorAll('a.yro-external-link')].map(x=>({href:x.href,target:x.target,rel:x.rel,label:x.getAttribute('aria-label')})),
      scriptSources:[...document.scripts].map(x=>x.src),forms:document.forms.length
    }));
    result.baselineRequests = [...result.requests];
    // Benign marker: no destructive payloads or external hosts.
    const marker='<img src=x onerror="window.__yroAuditMarker=1">';
    await p.goto('https://yro.audit.invalid/?q='+encodeURIComponent(marker)+'&url='+encodeURIComponent('javascript:window.__yroAuditMarker=2')+'#'+encodeURIComponent(marker),{waitUntil:'networkidle'});
    await enable(p);
    result.queryAndFragment = await p.evaluate(() => ({markerExecuted:window.__yroAuditMarker!==undefined,markerRendered:document.documentElement.innerHTML.includes('window.__yroAuditMarker'),title:document.title}));
    await p.getByRole('button',{name:'What We’ve Done',exact:true}).click();
    const outgoing=[];
    await context.route('https://tunings.io/**', async route=>{
      outgoing.push({url:route.request().url(),headers:await route.request().allHeaders()});
      await route.fulfill({contentType:'text/html',body:'<!doctype html><title>Controlled external destination</title><p>Audit destination</p>'});
    });
    result.externalLinks=[];
    for(const input of ['mouse','keyboard']) {
      const link=p.getByRole('link',{name:'Open tunings.io in a new tab',exact:true});
      const popupPromise=p.waitForEvent('popup');
      if(input==='mouse') await link.click();
      else { await link.focus(); await p.keyboard.press('Enter'); }
      const popup=await popupPromise;
      await popup.waitForLoadState('domcontentloaded');
      result.externalLinks.push({input,destination:popup.url(),openerIsNull:await popup.evaluate(()=>window.opener===null),parentStillOnSite:p.url().startsWith('https://yro.audit.invalid/'),referer:outgoing.at(-1)?.headers.referer??null});
      await popup.close();
    }
    const framePage=await context.newPage();
    await framePage.route('https://frame.audit.invalid/**',route=>route.fulfill({contentType:'text/html',body:'<!doctype html><iframe src="https://yro.audit.invalid/" width="1000" height="700"></iframe>'}));
    await framePage.goto('https://frame.audit.invalid/',{waitUntil:'networkidle'});
    result.withoutFrameHeader={appFrameLoaded:framePage.frames().some(f=>f.url()==='https://yro.audit.invalid/')};
    await framePage.close();
    const policy="default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; font-src 'self'; connect-src 'self'; worker-src 'self' blob:; object-src 'none'; base-uri 'self'; form-action 'none'; frame-ancestors 'none'";
    responseHeaders={'Content-Security-Policy':policy,'X-Content-Type-Options':'nosniff','Referrer-Policy':'no-referrer','X-Frame-Options':'DENY','Permissions-Policy':'camera=(), microphone=(), geolocation=()'};
    const protectedPage=await context.newPage();
    const violations=[];const protectedErrors=[];
    protectedPage.on('console',msg=>{if(msg.type()==='error')violations.push(msg.text());});
    protectedPage.on('pageerror',e=>protectedErrors.push(e.message));
    await protectedPage.goto('https://yro.audit.invalid/',{waitUntil:'networkidle'});
    let renders=false;let renderError=null;
    try { await enable(protectedPage); renders=true; } catch(error) {renderError=String(error);}
    result.candidateHeaders={headers:responseHeaders,appRendered:renders,renderError,consoleErrors:violations,pageErrors:protectedErrors};
    await protectedPage.close();
    const blockedFrame=await context.newPage();
    const frameErrors=[];blockedFrame.on('console',msg=>{if(msg.type()==='error')frameErrors.push(msg.text());});
    await blockedFrame.route('https://frame.audit.invalid/**',route=>route.fulfill({contentType:'text/html',body:'<!doctype html><iframe src="https://yro.audit.invalid/" width="1000" height="700"></iframe>'}));
    await blockedFrame.goto('https://frame.audit.invalid/',{waitUntil:'networkidle'});
    result.withFrameHeader={appFrameLoaded:blockedFrame.frames().some(f=>f.url()==='https://yro.audit.invalid/'),consoleErrors:frameErrors};
    await blockedFrame.close();
    return result;
  } finally {await context.close();}
}
