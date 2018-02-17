{ cacheEndpoints } = require './endpoints.coffee'

module.exports =
  network: (cache, request) ->
    fetch(request).then (response) ->
      if cacheEndpoints.find((url) -> request.url.match(url))
        cache.put(request, response.clone())
      response

  cache: (cache, request) ->
    cache.match(request).then (response) -> response
