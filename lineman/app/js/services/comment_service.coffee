angular.module('loomioApp').service 'CommentService',
  class CommentService
    constructor: (@$http) ->
    # i am here.. then append to discussion?
    add: (comment, discussion) ->
      @$http.post('/api/comments', comment).then (response) ->
        discussion.events.push response.data
