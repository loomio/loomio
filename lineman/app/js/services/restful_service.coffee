angular.module('loomioApp').factory 'RestfulService', ($http, EventService, RecordStoreService) ->
  class RestfulService
    resource_plural: 'undefined'

    endpoint_path: ->
      "/api/v1/#{@resource_plural}"

    constructor: ->

    fetch: (params, success, failure) ->
      $http.get(@endpoint_path(), { params: $.extend({ format: 'json' }, params) }).then (response) =>
        RecordStoreService.importRecords(response.data)
        success(response.data[@resource_plural]) if success?
      , (response) ->
        failure(response.data.error)

    create: (obj, success, failure) ->
      $http.post(@endpoint_path(), obj.params()).then (response) ->
        EventService.consume(response.data)
        success()
      , (response) ->
        failure(response.data.error)
