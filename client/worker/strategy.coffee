{ networkFirstEndpoints, cacheEndpoints } = require './endpoints.coffee'

module.exports =
  getResponse: (cache, request) ->
    strategiesFor(request).find (strategy) => @[strategy](cache, request)

  network: (cache, request) ->
    fetch(request).then (response) ->
      if cacheEndpoints.find (url) -> request.url.match(url)
        cache.put(request, response.clone())
      response

  cache: (cache, request) ->
    cache.match(request)

strategiesFor = (request) ->
  if networkFirstEndpoints.find (url) -> request.url.match(url)
    ['network', 'cache']
  else
    ['cache', 'network']
