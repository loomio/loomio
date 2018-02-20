self.addEventListener 'install', (event) ->
  event.waitUntil caches.open(cacheName).then((cache) ->
    cache.addAll [
      '<%= client_asset_path(:"app.js") %>',
      '<%= client_asset_path(:"app.min.css") %>',
      '<%= client_asset_path(:"vendor.min.js") %>',
      '/dashboard'
    ]
  )
