angular.module('loomioApp').factory 'RestfulClient', ($http) ->
  class RestfulClient
    resourcePlural: 'undefined'
    constructor: (resourcePlural) ->
      @resourcePlural = resourcePlural

    apiPrefix: "api/v1"

    paramsAsQuery: (params) ->
      parts = _.map _.keys(params, (key) -> params[key])

    encodeUriQuery = (s) ->
      s

    buildUrl: (url, params) ->
      return url unless params?
      url + "?" + window.jQuery.param(params)

    collectionPath: (params) ->
      "#{@apiPrefix}/#{@resourcePlural}"

    memberPath: (id, params) ->
      "#{@apiPrefix}/#{@resourcePlural}/#{id}"

    customPath: (path, params) ->
      "#{@apiPrefix}/#{@resourcePlural}/#{path}"

    get: (path, params, success, failure) ->
      url = @buildUrl(@customPath(path), params)
      $http.get(url).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    post: (path, params, success, failure) ->
      $http.post(@customPath(path), params).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    getMember: (keyOrId, success, failure) ->
      $http.get(@memberPath(keyOrId)).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    getCollection: (params, success, failure) ->
      url = @buildUrl(@collectionPath(), params)
      $http.get(url).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    create: (params, success, failure) ->
      $http.post(@collectionPath(), params).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    update: (id, params, success, failure) ->
      $http.patch(@memberPath(id), params).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    destroy: (id, success, failure) =>
      $http.delete(@memberPath(id)).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?
