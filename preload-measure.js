/* Simple preload measurement listener
   Logs preload-progress and preload-complete events and stores last run in localStorage
*/
(function(){
  const key = 'jk_preload_stats_v1';
  let runs = JSON.parse(localStorage.getItem(key) || '[]');

  window.addEventListener('preload-progress', (e) => {
    const d = e.detail || {};
    // Minimal live logging, avoid noisy output
    if(d && d.loaded && d.total && (d.loaded === d.total || d.loaded % 10 === 0)){
      console.log(`preload: ${d.loaded}/${d.total} ${d.url || ''}`);
    }
  });

  window.addEventListener('preload-complete', (e) => {
    const d = e.detail || {};
    const now = new Date().toISOString();
    const record = {when: now, total: d.total || 0, durationMs: Math.round(d.duration || 0)};
    runs.push(record);
    // keep last 10
    if(runs.length > 10) runs = runs.slice(runs.length-10);
    try{ localStorage.setItem(key, JSON.stringify(runs)); }catch(e){}
    console.log('Image preload complete:', record);
  });

})();
