angular.module('loomioApp').factory 'CommentService', ($http, UserAuthService) ->
  new class CommentService
    constructor: ->

    add: (comment, success, failure) ->
      $http.post('/api/v1/comments', comment).then (response) ->
        success()
      , (response) ->
        failure(response.data.error)

    like: (comment, success, failure) ->
      $http.post("/api/v1/comments/#{comment.id}/like").then (response) ->
        comment.addLiker(UserAuthService.currentUser)
        success()

    unlike: (comment, success, failure) ->
      $http.post("/api/v1/comments/#{comment.id}/unlike").then (response) ->
        comment.removeLiker(UserAuthService.currentUser)
        success()
