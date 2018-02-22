strategies                = require './strategies.coffee'
{ networkFirstEndpoints } = require './endpoints.coffee'

module.exports = (cache, request) ->
  # iterate through strategies until we find one with a response
  strategiesFor(request).reduce (result, strategy) ->
    result.then  (response) -> response || strategy(cache, request)
          .catch (response) -> strategy(cache, request)
  , Promise.resolve(undefined)

strategiesFor = (request) ->
  strategyNamesFor(request).map (name) -> strategies[name]

strategyNamesFor = (request) ->
  if networkFirstEndpoints.find((url) -> request.url.match(url))
    ['network', 'cache']
  else
    ['cache', 'network']
