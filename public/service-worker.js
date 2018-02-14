self.addEventListener('install', function(event) {
  console.log(location)
  let version = "development"
  event.waitUntil(
    caches.open('loomioApp').then((cache) => {
      cache.addAll([
        "/dashboard",
        "/api/v1/boot/site",
        "/api/v1/translations?lang=en",
        "/client/fonts/materialdesignicons-webfont.woff2?v=2.1.19",
        "/theme/default_group_logo.png"
      ])
      if (version != 'development') {
        cache.addAll([
          `/client/${version}/angular.min.css`,
          `/client/${version}/angular.bundle.min.js`
        ])
      }
    })
  )
})
