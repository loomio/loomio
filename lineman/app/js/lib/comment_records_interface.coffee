angular.module('loomioApp').factory 'CommentRecordsInterface', (BaseRecordsInterface, CommentModel) ->
  class CommentRecordsInterface extends BaseRecordsInterface
    @model: CommentModel

    like: (user, comment, success, failure) ->
      comment.addLiker(user)
      @restfulClient.post("#{comment.id}/like").then (response) ->
        success()

    unlike: (user, comment, success, failure) ->
      comment.removeLiker(user)
      @restfulClient.post("#{comment.id}/unlike").then (response) ->
        success()
