angular.module('loomioApp').factory 'PollRecordsInterface', (BaseRecordsInterface, PollModel) ->
  class PollRecordsInterface extends BaseRecordsInterface
    model: PollModel

    fetchByDiscussion: (discussionKey, options = {}) ->
      options['discussion_id'] = discussionKey
      @fetch
        params: options
