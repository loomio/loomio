angular.module('loomioApp').factory 'InboxService', ($http, Records) ->
  new class InboxService
    fetchPage: (page, success, failure) ->
      $http.get("/api/v1/inbox?page=#{page}").then (response) =>
        console.log response
        Records.import(response.data)

        ids = _.pluck response.data.discussions, 'id'
        discussions = Records.discussions.get(ids)
        success(discussions)

      , (response) ->
        failure(response.data.error)
