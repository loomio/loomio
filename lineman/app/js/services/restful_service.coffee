angular.module('loomioApp').factory 'RestfulService', ($http, EventService, RecordStoreService) ->
  class RestfulService
    resource_plural: 'undefined'

    indexPath: ->
      "/api/v1/#{@resource_plural}"

    showPath: (id) ->
      "/api/v1/#{@resource_plural}/#{id}"

    constructor: ->

    fetchByKey: (key, success, failure) ->
      $http.get(@showPath(key)).then (response) =>
        RecordStoreService.importRecords(response.data)
        RecordStoreService.get(@resource_plural, key)

    fetch: (filters, success, failure) ->
      $http.get(@indexPath(), { params: filters }).then (response) =>
        RecordStoreService.importRecords(response.data)
        success(response.data[@resource_plural]) if success?
      , (response) ->
        failure(response.data.error) if failure?

    create: (obj, success, failure) ->
      $http.post(@indexPath(), obj.params()).then (response) ->
        EventService.consume(response.data)
        success()
      , (response) ->
        failure(response.data.error)

    update: (obj, success, failure) ->
      $http.patch(@showPath(obj.id), obj.params()).then (response) ->
        EventService.consume(response.data)
        success()
      , (response) ->
        failure(response.data.error)

    delete: (obj, success, failure) ->
      $http.delete(@showPath(obj.id), obj.params()).then (response) ->
        RecordStoreService.delete(obj)
        success()
      , (response) ->
        console.log response
        failure(response.data.error)

    save: (obj, success, failure) ->
      console.log 'isnew', obj.isNew()
      if obj.isNew()
        @create(obj, success, failure)
      else
        @update(obj, success, failure)
