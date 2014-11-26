angular.module('loomioApp').factory 'InboxService', ($http, MainRecordStore) ->
  new class InboxService
    fetchPage: (page, success, failure) ->
      $http.get("/api/v1/inbox?page=#{page}").then (response) =>
        console.log response
        MainRecordStore.importRecords(response.data)

        # return discussions in the order they arrived
        ordered_ids = _.map response.data.discussions, (discussion) -> discussion.id
        discussions = MainRecordStore.discussions.get(ordered_ids)
        success(discussions)
      , (response) ->
        failure(response.data.error)
