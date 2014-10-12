angular.module('loomioApp').service 'CommentService',
  class CommentService
    constructor: (@$http, @EventService) ->
    # i am here.. then append to discussion?
    add: (comment, saveSuccess, saveError) ->
      @$http.post('/api/v1/comments', comment).then (response) =>
        @EventService.consumeEventFromResponseData(response.data)
        saveSuccess(response.data.event)
      , (response) ->
        saveError(response.data.error)

    like: (comment) ->
      @$http.post("/api/v1/comments/#{comment.id}/like").then (response) ->
        data = response.data
        comment.liker_ids_and_names[data.id] = data.name

    unlike: (comment) ->
      @$http.post("/api/v1/comments/#{comment.id}/unlike").then (response) ->
        data = response.data
        delete comment.liker_ids_and_names[data.id]
