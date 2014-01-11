angular.module('loomioApp').service 'DiscussionService',
  class DiscussionService
    constructor: (@$http, @RecordCacheService) ->

    remoteGet: (id) ->
      @$http.get("/api/discussions/#{id}").then (response) =>
        @RecordCacheService.consumeSideLoadedRecords(response.data)
        discussion = response.data.discussion
        @RecordCacheService.hydrateRelationshipsOn(discussion)
        discussion
      , (response) ->
        saveError(response.data.error)
