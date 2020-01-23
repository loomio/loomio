import { encodeParams } from '@/shared/helpers/encode_params'

export default class RestfulClient
  defaultParams: {}
  currentUpload: null
  apiPrefix: "/api/v1"

  # override these to set default actions
  onPrepare: (request)  -> request
  onCleanup: (response) -> response
  onSuccess: (response) -> response
  onFailure: (response) -> throw response
  onUploadSuccess: (response) -> response

  constructor: (resourcePlural) ->
    @defaultParams.unsubscribe_token = new URLSearchParams(location.search).get('unsubscribe_token')
    @defaultParams.membership_token = new URLSearchParams(location.search).get('membership_token')
    @defaultParams = _.omitBy(@defaultParams, _.isNil)
    @processing = []
    @resourcePlural = _.snakeCase(resourcePlural)

  buildUrl: (path, params) ->
    path = _.compact([@apiPrefix, @resourcePlural, path]).join('/')
    return path unless params?
    path + "?" + encodeParams(params)

  memberPath: (id, action) ->
    _.compact([id, action]).join('/')

  fetchById: (id, params = {}) ->
    @getMember(id, '', params)

  fetch: ({params, path}) ->
    @get(path or '', params)

  post: (path, params) ->
    @request @buildUrl(path), 'POST', @paramsFor(params)

  patch: (path, params) ->
    @request @buildUrl(path), 'PATCH', @paramsFor(params)

  delete: (path, params) ->
    @request @buildUrl(path), 'DELETE', @paramsFor(params)

  # NB: get requests place their params into the query string, rather than the request body
  get: (path, params) ->
    @request @buildUrl(path, @paramsFor(params)), 'GET'

  request: (path, method, body = {}) ->
    opts =
      method:      method
      credentials: 'same-origin'
      headers:     { 'Content-Type': 'application/json' }
      body:        JSON.stringify(body)
    delete opts.body if method == 'GET'
    @onPrepare()
    fetch(path, opts).then (response) =>
      if response.ok
        @onSuccess(response)
      else
        @onFailure(response)
    , (response) =>
      @onFailure(response)
    .finally(@onCleanup)

  postMember: (keyOrId, action, params) ->
    @post(@memberPath(keyOrId, action), params)

  patchMember: (keyOrId, action, params) ->
    @patch(@memberPath(keyOrId, action), params)

  getMember: (keyOrId, action = '', params) ->
    @get(@memberPath(keyOrId, action), params)

  create: (params) ->
    @post('', params)

  update: (id, params) ->
    @patch(id, params)

  destroy: (id, params) ->
    @delete(id, params)

  upload: (path, file, options = {}, onProgress) ->
    new Promise (resolve, reject) =>
      data = new FormData();
      data.append(options.fileField     || 'file',     file)
      data.append(options.filenameField || 'filename', file.name.replace(/[^a-z0-9_\-\.]/gi, '_'))

      @currentUpload = new XMLHttpRequest()
      @currentUpload.open('POST', @buildUrl(path), true)
      @currentUpload.responseType = 'json'
      @currentUpload.addEventListener 'load', =>
        if (@currentUpload.status >= 200 && @currentUpload.status < 300)
          @currentUpload.response = JSON.parse(@currentUpload.response) if _.isString(@currentUpload.response)
          @onUploadSuccess(@currentUpload.response)
          resolve(@currentUpload.response)
          @currentUpload = null
      @currentUpload.upload.addEventListener('progress', onProgress) if onProgress
      @currentUpload.addEventListener('error', reject)
      @currentUpload.addEventListener('abort', reject)
      @currentUpload.send(data)

  abort: ->
    @currentUpload.abort() if @currentUpload

  paramsFor: (params) ->
    _.defaults({}, @defaultParams, _.pickBy(params, _.identity))
