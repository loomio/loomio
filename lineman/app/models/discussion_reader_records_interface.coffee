angular.module('loomioApp').factory 'DiscussionReaderRecordsInterface', (BaseRecordsInterface, DiscussionReaderModel) ->
  class DiscussionReaderRecordsInterface extends BaseRecordsInterface
    model: DiscussionReaderModel

    initialize: (data = {}) ->
      data.id = data.discussion_id if data.discussion_id?
      @baseInitialize(data)
