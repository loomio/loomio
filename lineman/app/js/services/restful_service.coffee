angular.module('loomioApp').factory 'RestfulService', ($http) ->
  class RestfulService
    resource_plural: 'undefined'

    endpoint_path: ->
      "/api/v1/#{@resource_plural}"

    constructor: ->

    create: (obj, success, failure) ->
      $http.post(@endpoint_path(), obj.params()).then (response) ->
        success()
      , (response) ->
        failure(response.data.error)
