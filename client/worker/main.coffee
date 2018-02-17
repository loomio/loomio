{ assetEndpoints } = require './endpoints.coffee'
{ performFetch }   = require './strategy.coffee'

self.addEventListener 'install', (event) ->
  caches.open('loomioApp').then (cache) ->
    event.waitUntil cache.addAll(assetEndpoints(location.pathname.split('/')[2]))

self.addEventListener 'fetch', (event) ->
  caches.open('loomioApp').then (cache) ->
    event.respondWith getResponse(cache, event.request)
