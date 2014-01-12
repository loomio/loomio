angular.module('loomioApp').service 'DiscussionService',
  class DiscussionService
    constructor: (@$http, @RecordCacheService) ->

    remoteGet: (id) ->
      @$http.get("/api/discussions/#{id}").then (response) =>
        discussion = response.data.discussion
        @RecordCacheService.consumeSideLoadedRecords(response.data)
        @RecordCacheService.hydrateRelationshipsOn(discussion)
        @RecordCacheService.put('discussions', discussion.id, discussion)
        console.log('discussion: ', discussion)
        console.log('discussion get just after put', @RecordCacheService.get('discussions', discussion.id))
        discussion
      , (response) ->
        saveError(response.data.error)
