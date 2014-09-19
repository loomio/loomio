angular.module('loomioApp').service 'DiscussionService',
  class DiscussionService
    constructor: (@$http, @RecordCacheService) ->

    remoteGet: (id) ->
      @$http.get("/api/v1/discussions/#{id}").then (response) =>
        discussion = response.data.discussion
        @RecordCacheService.consumeSideLoadedRecords(response.data)
        @RecordCacheService.hydrateRelationshipsOn(discussion)
        @RecordCacheService.put('discussions', discussion.id, discussion)
        discussion
      , (response) ->
        saveError(response.data.error)
