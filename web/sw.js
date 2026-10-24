const CACHE='nayyet-v5';const FILES=['./','./index.html','./styles.css','./app.js','./quote-export.js','./calendar.js','./icon.svg','./icon-192.png','./icon-512.png','./manifest.webmanifest','./assets/calendar.json','./assets/fonts/Pyidaungsu.ttf','./assets/fonts/Outfit.ttf'];
for(let i=1;i<=12;i++)FILES.push('./assets/themes/theme-'+String(i).padStart(2,'0')+'.png');
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(FILES)).then(()=>self.skipWaiting())));
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith('nayyet-')&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',e=>{if(e.request.method==='GET'&&new URL(e.request.url).origin===location.origin)e.respondWith(caches.match(e.request).then(cached=>cached||fetch(e.request)))});
