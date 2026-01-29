const SW_VERSION = 'v1';
const CACHE_PREFIX = 'jk-images-';
const IMAGE_CACHE = `${CACHE_PREFIX}${SW_VERSION}`;
const SHELL_CACHE = `jk-shell-${SW_VERSION}`;
const MAX_IMAGE_ENTRIES = 80; // limit number of images cached to avoid unbounded growth

const SHELL_FILES = [
  '/',
  '/index.html',
  '/style.css',
  '/script.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(SHELL_CACHE)
      .then(cache => cache.addAll(SHELL_FILES))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.filter(k => k !== IMAGE_CACHE && k !== SHELL_CACHE).map(k => caches.delete(k))
    )).then(() => self.clients.claim())
  );
});

// Stale-while-revalidate for images under /photos/
self.addEventListener('fetch', event => {
  const req = event.request;
  const url = new URL(req.url);

  // Only handle GET requests
  if (req.method !== 'GET') return;

  // Fast path for same-origin images in /photos/
  if (url.origin === location.origin && url.pathname.startsWith('/photos/')) {
    event.respondWith((async () => {
      const cache = await caches.open(IMAGE_CACHE);
      const cached = await cache.match(req);

      const networkFetch = fetch(req).then(networkResp => {
        if(networkResp && networkResp.status === 200){
          cache.put(req, networkResp.clone()).catch(()=>{}).then(async ()=>{
            // enforce max entries (simple FIFO eviction)
            try{
              const keys = await cache.keys();
              if(keys.length > MAX_IMAGE_ENTRIES){
                // delete oldest entries until under limit
                const removeCount = keys.length - MAX_IMAGE_ENTRIES;
                for(let i=0;i<removeCount;i++){
                  await cache.delete(keys[i]).catch(()=>{});
                }
              }
            }catch(e){ /* ignore eviction errors */ }
          });
        }
        return networkResp;
      }).catch(()=>null);

      // Return cached immediately if available, otherwise wait for network
      return cached || networkFetch || new Response(null, {status: 503});
    })());
    return;
  }

  // Default: fallback to network
});
