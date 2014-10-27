angular.module('loomioApp').factory 'RestfulService', ($http, EventService) ->
  class RestfulService
    resource_plural: 'undefined'

    endpoint_path: ->
      "/api/v1/#{@resource_plural}"

    constructor: ->

    create: (obj, success, failure) ->
      $http.post(@endpoint_path(), obj.params()).then (response) ->
        EventService.consume(response.data)
        success()
      , (response) ->
        failure(response.data.error)
