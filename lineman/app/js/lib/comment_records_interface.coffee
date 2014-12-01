angular.module('loomioApp').factory 'CommentRecordsInterface', (BaseRecordsInterface, CommentModel) ->
  class CommentRecordsInterface extends BaseRecordsInterface
    model: CommentModel

    like: (user, comment, success) ->
      comment.addLiker(user)
      @restfulClient.post "#{comment.id}/like"

    unlike: (user, comment, success) ->
      comment.removeLiker(user)
      @restfulClient.post "#{comment.id}/unlike"
