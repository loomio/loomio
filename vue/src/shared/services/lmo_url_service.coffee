import AppConfig             from '@/shared/services/app_config'

export default class LmoUrlService
  @shareableLink: (model) ->
    if model.isA('group')
      @buildModelRoute('', model.token, '', {}, namespace: 'join/group', absolute: true)
    else
      @route(model: model, options: {absolute: true})

  @route: ({model, action, params, options}) ->
    if model? and action?
      @[model.constructor.singular](model, {}, {noStub: true}) + @routePath(action)
    else if model?
      @[model.constructor.singular](model, params, options)
    else
      @routePath(action)

  @routePath: (route) ->
    "/".concat(route).replace('//', '/')

  @group: (g, params = {}, options = {}) ->
    if g.handle? && !options.noStub
      @buildModelRoute('', g.handle, '', params, options)
    else
      @buildModelRoute('g', g.key, g.fullName, params, options)

  @discussion: (d, params = {}, options = {}) ->
    @buildModelRoute('d', d.key, options.action or d.title, params, options)

  @poll: (p, params = {}, options = {}) ->
    @buildModelRoute('p', p.key, options.action or p.title, params, options)

  @outcome: (o, params = {}, options = {}) ->
    @poll(o.poll(), params, options)

  @pollSearch: (params = {}, options = {}) ->
    @buildModelRoute('polls', '', options.action, params, options)

  @searchResult: (r, params = {}, options = {}) ->
    @discussion r, params, options

  @user: (u, params = {}, options = {}) ->
    @buildModelRoute('u', u[options.key || 'username'], null, params, options)

  @comment: (c, params = {}) ->
    @route model: c.discussion(), action: "comment/#{c.id}", params: params

  @membership: (m, params = {}, options = {}) ->
    @route model: m.group(), action: 'memberships', params: params

  @membershipRequest: (mr, params = {}, options = {}) ->
    @route model: mr.group(), action: 'membership_requests', params: params

  @event: (e, params = {}, options = {}) ->
    @discussion(e.discussion(), params, options) + "/#{e.sequenceId}"

  @buildModelRoute: (path, key, name, params, options) ->
    result = if options.absolute then AppConfig.baseUrl else "/"
    result += "#{options.namespace || path}/" if (options.namespace || path || "").length > 0
    result += "#{key}"
    result += "/" + @stub(name)             unless !name? or options.noStub?
    result += "." + options.ext             if options.ext?
    result += "?" + @queryStringFor(params) if _.keys(params).length
    result

  @stub: (name) ->
    name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()

  @queryStringFor: (params = {}) ->
    _.map(params, (value, key) -> "#{key}=#{value}").join('&')
