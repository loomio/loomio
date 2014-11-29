angular.module('loomioApp').factory 'RestfulClient', ($http) ->
  class RestfulClient
    constructor: (resource_plural) ->
      @resource_plural = resource_plural

    resource_plural: 'undefined'

    apiPrefix: "api/v1"

    indexPath: ->
      "#{@apiPrefix}/#{@resource_plural}"

    showPath: (id) ->
      "#{@apiPrefix}/#{@resource_plural}/#{id}"

    customPath: (path, id) ->
      if path?
        if id?
          "#{@apiPrefix}/#{@resource_plural}/#{id}/#{path}"
        else
          "#{@apiPrefix}/#{@resource_plural}/#{path}"

    fetchByKey: (key, success, failure) ->
      $http.get(@showPath(key)).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?


    fetch: (filters, success, failure, path) ->
      path = @customPath(path) or @indexPath()
      $http.get(path, { params: filters }).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    create: (obj, success, failure, path) ->
      path = @customPath(path) or @indexPath()
      $http.post(path, obj.serialize()).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    update: (obj, success, failure, path) ->
      path = @customPath(path, obj.id) or @showPath(obj.id)
      $http.patch(path, obj.serialize()).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    destroy: (obj, success, failure) =>
      $http.delete(@showPath(obj.id)).then (response) ->
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    save: (obj, success, failure, path) =>
      if obj.isNew()
        @create(obj, success, failure, path)
      else
        @update(obj, success, failure, path)
