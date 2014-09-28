angular.module('loomioApp').service 'DiscussionService',
  class DiscussionService
    constructor: (@$http, @RecordStoreService) ->

    fetchByKey: (key) ->
      @$http.get("/api/v1/discussions/#{key}").then (response) =>
        @RecordStoreService.importRecords(response.data)
        record = @RecordStoreService.getByKey('discussions', key)
        record
      , (response) ->
        saveError(response.data.error)
