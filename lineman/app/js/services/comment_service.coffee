angular.module('loomioApp').service 'CommentService',
  class CommentService
    constructor: (@$http) ->
    # i am here.. then append to discussion?
    add: (comment, discussion) ->
      @$http.post('/api/comments', comment).then (response) ->
        discussion.events.push response.data.event

    like: (comment) ->
      @$http.post("/api/comments/#{comment.id}/like").then (response) ->
        data = response.data
        comment.liker_ids_and_names[data.id] = data.name

    unlike: (comment) ->
      @$http.post("/api/comments/#{comment.id}/unlike").then (response) ->
        data = response.data
        delete comment.liker_ids_and_names[data.id]
