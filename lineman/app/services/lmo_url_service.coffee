angular.module('loomioApp').factory 'LmoUrlService', ->
  new class LmoUrlService

    group: (g, params) ->
      "/g/#{g.key}/#{@stub(g.fullName())}#{@queryStringFor(params)}"

    discussion: (d, params = {}) ->
      "/d/#{d.key}/#{@stub(d.title)}#{@queryStringFor(params)}"

    proposal: (p, params = {}) ->
      "/m/#{p.key}/#{@stub(p.name)}#{@queryStringFor(params)}"

    comment: (c, params = {}) ->
      @discussion c.discussion(), _.merge(params, {comment: c.key})

    stub: (name) ->
      name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()

    queryStringFor: (params = {}) ->
      queryString = _.map(params, (value, key) -> "#{key}=#{value}").join('&')
      if queryString.length then "?#{queryString}" else ''
