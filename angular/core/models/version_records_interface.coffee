angular.module('loomioApp').factory 'VersionRecordsInterface', (BaseRecordsInterface, VersionModel) ->
  class VersionRecordsInterface extends BaseRecordsInterface
    model: VersionModel

    fetchByDiscussion: (discussionKey, options = {}) ->
      @fetch
        params:
          model: 'discussion'
          discussion_id: discussionKey

    fetchByComment: (commentId, options = {}) ->
      @fetch
        params:
          model: 'comment'
          comment_id: commentId
