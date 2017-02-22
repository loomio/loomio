angular.module('loomioApp').factory 'LmoUrlService', (AppConfig) ->
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
      @buildModelRoute('g', g.key, g.fullName, params, options)

    discussion: (d, params = {}, options = {}) ->
      @buildModelRoute('d', d.key, d.title, params, options)

    poll: (p, params = {}, options = {}) ->
      @buildModelRoute('p', p.key, options.action or p.title, params, options)

    searchResult: (r, params = {}, options = {}) ->
      @discussion r, params, options

    user: (u, params = {}, options = {}) ->
      @buildModelRoute('u', u[options.key || 'username'], null, params, options)

    proposal: (p, params = {}) ->
      @route model: p.discussion(), action: "proposal/#{p.key}", params: params

    comment: (c, params = {}) ->
      @route model: c.discussion(), action: "comment/#{c.id}", params: params

    membership: (m, params = {}, options = {}) ->
      @route model: m.group(), action: 'memberships', params: params

    membershipRequest: (mr, params = {}, options = {}) ->
      @route model: mr.group(), action: 'membership_requests', params: params

    visitor: ->
      # NOOP for now

    oauthApplication: (a, params = {}, options = {}) ->
      @buildModelRoute('apps/registered', a.id, a.name, params, options)

    contactForm: ->
      AppConfig.baseUrl + '/contact'

    buildModelRoute: (path, key, name, params, options) ->
      result = if options.absolute then AppConfig.baseUrl else "/"
      result += "#{options.namespace || path}/#{key}"
      result += "/" + @stub(name)             unless !name? or options.noStub?
      result += "." + options.ext             if options.ext?
      result += "?" + @queryStringFor(params) if _.keys(params).length
      result

    stub: (name) ->
      name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()

    queryStringFor: (params = {}) ->
      _.map(params, (value, key) -> "#{key}=#{value}").join('&')
