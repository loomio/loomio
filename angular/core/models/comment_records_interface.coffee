angular.module('loomioApp').factory 'CommentRecordsInterface', (BaseRecordsInterface, CommentModel) ->
  class CommentRecordsInterface extends BaseRecordsInterface
    model: CommentModel

    like: (user, comment, success) ->
      @remote.postMember comment.id, "like"

    unlike: (user, comment, success) ->
      @remote.postMember comment.id, "unlike"
