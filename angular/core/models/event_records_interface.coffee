angular.module('loomioApp').factory 'EventRecordsInterface', (BaseRecordsInterface, EventModel) ->
  class EventRecordsInterface extends BaseRecordsInterface
    model: EventModel

    fetchByDiscussion: (discussionKey, options = {}) ->
      @fetch
        params:
          discussion_key: discussionKey
          from: options['from']
          comment_id: options['comment_id']
          per: options['per']

    findByDiscussionAndSequenceId: (discussion, sequenceId) ->
      @collection.chain()
                 .find(discussionId: discussion.id)
                 .find(sequenceId: sequenceId)
                 .data()[0] # so, turns out finding by multiple parameters doesn't actually work..
