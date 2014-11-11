angular.module('loomioApp').factory 'CommentService', ($http, UserAuthService, RestfulService, RecordStoreService) ->
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

    destroy: (obj, success, failure) ->
      $http.delete(@showPath(obj.id), obj.params()).then (response) ->
        obj.destroy()
        success()
      , (response) ->
        console.log response
        failure(response.data.error)
