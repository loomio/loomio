angular.module('loomioApp').factory 'RestfulService', ($http, EventService, RecordStoreService) ->
  class RestfulService
    resource_plural: 'undefined'

    indexPath: ->
      "/api/v1/#{@resource_plural}.json" 

    showPath: (id) ->
      "/api/v1/#{@resource_plural}/#{id}.json"

    constructor: ->

    fetchOne: (key, success, failure) ->
      $http.get(@showPath(key)).then (response) =>
        RecordStoreService.importRecords(response.data)
        RecordStoreService.get(@resource_plural, key)

    fetch: (filters, success, failure) ->
      $http.get(@indexPath(), { params: filters }).then (response) =>
        RecordStoreService.importRecords(response.data)
        success(response.data[@resource_plural]) if typeof success == 'function'
      , (response) ->
        failure(response.data.error)             if typeof failure == 'function'

    create: (obj, success, failure) ->
      $http.post(@indexPath(), obj.params()).then (response) ->
        EventService.consume(response.data)
        success()
      , (response) ->
        failure(response.data.error)
