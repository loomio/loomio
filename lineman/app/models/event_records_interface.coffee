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

    minLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.min @find(discussionId: discussion.id), (event) -> event.sequenceId or Number.MAX_VALUE
      item.sequenceId

    maxLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.max @find(discussionId: discussion.id), (event) -> event.sequenceId or 0
      item.sequenceId
