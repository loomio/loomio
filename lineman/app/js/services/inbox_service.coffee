angular.module('loomioApp').factory 'InboxService', ($http, Records) ->
  new class InboxService
    fetchPage: (page, success, failure) ->
      $http.get("/api/v1/inbox?page=#{page}").then (response) =>
        console.log response
        Records.import(response.data)

        # return discussions in the order they arrived
        ids = _.map response.data.discussions, (discussion) -> discussion.id
        console.log ids
        discussions = Records.discussions.get(ids)
        success(discussions)
      , (response) ->
        failure(response.data.error)
