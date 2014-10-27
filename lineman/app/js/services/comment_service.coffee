angular.module('loomioApp').factory 'CommentService', ($http, UserAuthService, RestfulService) ->
  new class CommentService extends RestfulService
    resource_plural: 'comments'

    like: (comment, success, failure) ->
      comment.addLiker(UserAuthService.currentUser)
      $http.post("/api/v1/comments/#{comment.id}/like").then (response) ->
        success()

    unlike: (comment, success, failure) ->
      comment.removeLiker(UserAuthService.currentUser)
      $http.post("/api/v1/comments/#{comment.id}/unlike").then (response) ->
        success()
