angular.module('loomioApp').factory 'InboxService', ($http, Records) ->
  new class InboxService
    fetchPage: (page, success, failure) ->
      $http.get("/api/v1/inbox?page=#{page}").then (data) ->
        Records.import(data)
        ids = _.map data.discussions, (discussion) -> discussion.id
        discussions = Records.discussions.find(ids)
        success(discussions)
      ,
        (data) ->
        failure(data.error)
