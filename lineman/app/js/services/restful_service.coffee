angular.module('loomioApp').factory 'RestfulService', ($http, MessageChannelService, RecordStoreService) ->
  class RestfulService
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

    constructor: ->

    fetchByKey: (key, success, failure) ->
      $http.get(@showPath(key)).then (response) =>
        RecordStoreService.importRecords(response.data)
        RecordStoreService.get(@resource_plural, key)

    fetch: (filters, success, failure, path) ->
      path = @customPath(path) or @indexPath()
      $http.get(path, { params: filters }).then (response) =>
        RecordStoreService.importRecords(response.data)
        success(response.data[@resource_plural]) if success?
      , (response) ->
        failure(response.data) if failure?

    create: (obj, success, failure, path) ->
      path = @customPath(path) or @indexPath()
      $http.post(path, obj.params()).then (response) ->
        MessageChannelService.messageReceived(response.data)
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    update: (obj, success, failure, path) ->
      path = @customPath(path, obj.id) or @showPath(obj.id)
      $http.patch(path, obj.params()).then (response) ->
        MessageChannelService.messageReceived(response.data)
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    destroy: (obj, success, failure) ->
      $http.delete(@showPath(obj.id)).then (response) ->
        MessageChannelService.messageReceived(response.data)
        success(response.data) if success?
      , (response) ->
        failure(response.data) if failure?

    save: (obj, success, failure, path) ->
      if obj.isNew()
        @create(obj, success, failure, path)
      else
        @update(obj, success, failure, path)
