angular.module('loomioApp').service 'CommentService',
  class CommentService
    constructor: (@$http, @EventService) ->
    # i am here.. then append to discussion?
    add: (comment, success, failure) ->
      @$http.post('/api/v1/comments', comment).then (response) ->
        success()
      , (response) ->
        failure(response.data.error)

    like: (comment, success, failure) ->
      @$http.post("/api/v1/comments/#{comment.id}/like").then (response) ->
        comment.likerIds.push response.data.id

    unlike: (comment) ->
      @$http.post("/api/v1/comments/#{comment.id}/unlike").then (response) ->
        comment.likerIds = _.without(comment.likerIds, response.data.id)
