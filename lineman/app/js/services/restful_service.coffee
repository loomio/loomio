angular.module('loomioApp').factory 'RestfulService', ($http, MessageChannelService, RecordStoreService) ->
  class RestfulService
    resource_plural: 'undefined'

    apiPrefix: "api/v1"

    indexPath: ->
      "#{@apiPrefix}/#{@resource_plural}"

    showPath: (id) ->
      "#{@apiPrefix}/#{@resource_plural}/#{id}"

    customPath: (path) ->
      if path?
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
        failure(response.data.error) if failure?

    create: (obj, success, failure) ->
      $http.post(@indexPath(), obj.params()).then (response) ->
        MessageChannelService.messageReceived(response.data)
        success()
      , (response) ->
        failure(response.data.error)

    update: (obj, success, failure) ->
      $http.patch(@showPath(obj.id), obj.params()).then (response) ->
        MessageChannelService.messageReceived(response.data)
        success()
      , (response) ->
        failure(response.data.error)

    destroy: (obj, success, failure) ->
      $http.delete(@showPath(obj.id), obj.params()).then (response) ->
        MessageChannelService.messageReceived(response.data)
        success()
      , (response) ->
        console.log response
        failure(response.data.error)

    save: (obj, success, failure) ->
      console.log 'saving'
      console.log 'isnew', obj.isNew()
      if obj.isNew()
        @create(obj, success, failure)
      else
        @update(obj, success, failure)
