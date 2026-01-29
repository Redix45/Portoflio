/* Deferred image preloader
   - Preloads thumbnail URLs found in the page's <picture>/<img> markup
   - Runs after window load and uses requestIdleCallback or a throttled loop
   - Config: set `preloadFullImages = true` to also fetch larger sources from srcset
*/
(function(){
  const preloadFullImages = true; // set true to also preload large/full images
  const budgetMs = 50; // work budget per idle chunk

  function parseSrcFromSrcset(srcset, preferLargest){
    if(!srcset) return null;
    const parts = srcset.split(',').map(s=>s.trim()).filter(Boolean);
    if(parts.length===0) return null;
    const pick = preferLargest ? parts[parts.length-1] : parts[0];
    return pick.split(' ')[0];
  }

  function collectUrls(){
    const urls = new Set();
    document.querySelectorAll('picture source, img').forEach(el => {
      const tag = el.tagName.toLowerCase();
      if(tag === 'source'){
        const ss = el.getAttribute('srcset');
        const url = parseSrcFromSrcset(ss, preloadFullImages);
        if(url) urls.add(url);
      } else if(tag === 'img'){
        const src = el.getAttribute('src');
        if(src) urls.add(src);
        const ss = el.getAttribute('srcset');
        const url = parseSrcFromSrcset(ss, preloadFullImages);
        if(url) urls.add(url);
      }
    });
    return Array.from(urls).filter(Boolean);
  }

  function preloadUrl(url, onLoaded){
    try{
      const i = new Image();
      i.decoding = 'async';
      i.onload = function(){ try{ onLoaded(true, url); }catch(e){} };
      i.onerror = function(){ try{ onLoaded(false, url); }catch(e){} };
      // Start load after handlers attached
      i.src = url;
    }catch(e){ try{ onLoaded(false, url); }catch(err){} }
  }

  function startPreload(){
    const urls = collectUrls();
    if(urls.length===0) return;
    let i = 0;
    let loadedCount = 0;
    const total = urls.length;
    const startedAt = performance.now();

    function onLoaded(success, url){
      loadedCount++;
      const evt = new CustomEvent('preload-progress', {detail:{url, success, loaded: loadedCount, total}});
      window.dispatchEvent(evt);
      if(loadedCount >= total){
        const duration = performance.now() - startedAt;
        window.dispatchEvent(new CustomEvent('preload-complete', {detail:{total, duration}}));
      }
    }

    function work(){
      const start = performance.now();
      while(i < urls.length && (performance.now() - start) < budgetMs){
        preloadUrl(urls[i++], onLoaded);
      }
      if(i < urls.length){
        if('requestIdleCallback' in window){
          requestIdleCallback(work, {timeout:2000});
        } else {
          setTimeout(work, 200);
        }
      }
    }
    // Give the page a short moment for critical resources, then use idle time
    if('requestIdleCallback' in window){
      requestIdleCallback(work, {timeout:2000});
    } else {
      setTimeout(work, 600);
    }
  }

  if(document.readyState === 'complete'){
    setTimeout(startPreload, 400);
  } else {
    window.addEventListener('load', function(){ setTimeout(startPreload, 400); }, {once:true});
  }

})();
