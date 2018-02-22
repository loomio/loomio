{ staticEndpoints, networkFirstEndpoints } = require './endpoints.coffee'
cachedEndpoints = staticEndpoints.concat(networkFirstEndpoints)

module.exports =
  network: (cache, request) ->
    fetch(request).then (response) ->
      if cachedEndpoints.find((url) -> request.url.match(url))
        cache.put(request, response.clone())
      response

  cache: (cache, request) ->
    cache.match(request).then (response) -> response
