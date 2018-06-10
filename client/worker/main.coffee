{ assetEndpoints } = require './endpoints.coffee'
performFetch       = require './fetch.coffee'

self.addEventListener 'install', (event) ->
  version = location.search.replace('?', '')
  event.waitUntil(
    caches.open('loomioApp').then (cache) -> cache.addAll(assetEndpoints(version))
  )

self.addEventListener 'fetch', (event) ->
  event.respondWith(
    caches.open('loomioApp').then (cache) -> performFetch(cache, event.request)
  )

self.addEventListener 'beforeinstallprompt', (event) ->
  event.prompt()
