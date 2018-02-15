self.addEventListener('install', (event) => {
  let version = location.search.split('?')[1] || 'development'
  event.waitUntil(
    caches.open('loomioApp').then((cache) => {
      cache.addAll([
        "/dashboard",
        "/api/v1/boot/site",
        "/api/v1/translations?lang=en",
        "/client/fonts/materialdesignicons-webfont.woff2?v=2.1.19",
        "/theme/default_group_logo.png"
      ])
      if (version == 'development') {
        cache.addAll([
          `http://localhost:4002/client/${version}/angular.bundle.js`,
          `/client/${version}/angular.css`
        ])
      } else {
        cache.addAll([
          `/client/${version}/angular.min.css`,
          `/client/${version}/angular.bundle.min.js`
        ])
      }
    })
  )
})

self.addEventListener('fetch', (event) => {
  event.respondWith(caches.match(event.request).then((response) => {
    return response || fetch(event.request)
  }))
})
