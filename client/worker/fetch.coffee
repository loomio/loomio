Strategies                = require './strategies.coffee'
{ networkFirstEndpoints } = require './endpoints.coffee'

module.exports = (cache, request) ->
  for strategy in strategiesFor(request)
    result = result || Strategies[strategy](cache, request)
  result

strategiesFor = (request) ->
  if networkFirstEndpoints.find((url) -> request.url.match(url))
    ['network', 'cache']
  else
    ['cache', 'network']
