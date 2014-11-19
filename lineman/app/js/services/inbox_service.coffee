angular.module('loomioApp').factory 'InboxService', ($http, RecordStoreService) ->
  new class InboxService
    fetchPage: (page, success, failure) ->
      $http.get("/api/v1/inbox?page=#{page}").then (response) =>
        console.log response
        RecordStoreService.importRecords(response.data)

        # return discussions in the order they arrived
        ordered_ids = _.map response.data.discussions, (discussion) -> discussion.id
        discussions = RecordStoreService.get('discussions', ordered_ids)
        success(discussions)
      , (response) ->
        failure(response.data.error)
