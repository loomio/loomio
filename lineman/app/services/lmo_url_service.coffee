angular.module('loomioApp').factory 'LmoUrlService', ->
  new class LmoUrlService

    route: ({model, action, params}) ->
      if model? and action?
        @[model.constructor.singular](model, {}, {noStub: true}) + @routePath(action)
      else if model?
        @[model.constructor.singular](model)
      else
        @routePath(action)

    routePath: (route) ->
      "/".concat(route).replace('//', '/')

    group: (g, params = {}, options = {}) ->
      @buildModelRoute('g', g.key, g.fullName(), params, options)

    discussion: (d, params = {}, options = {}) ->
      @buildModelRoute('d', d.key, d.title, params, options)

    proposal: (p, params = {}, options = {}) ->
      @buildModelRoute('m', p.key, p.name, params, options)

    comment: (c, params = {}, options = {}) ->
      @discussion c.discussion(), _.merge(params, {comment: c.id})

    buildModelRoute: (path, key, name, params, options) ->
      result = "/#{path}/#{key}"
      result += "/" + @stub(name) unless options.noStub?
      result += "?" + @queryStringFor(params) if Object.keys(params).length
      result

    stub: (name) ->
      name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()

    queryStringFor: (params = {}) ->
      _.map(params, (value, key) -> "#{key}=#{value}").join('&')
