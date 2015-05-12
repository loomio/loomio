angular.module('loomioApp').factory 'EventRecordsInterface', (BaseRecordsInterface, EventModel) ->
  class EventRecordsInterface extends BaseRecordsInterface
    model: EventModel

    fetchByDiscussion: (discussionKey, options = {}) ->
      @fetch
        params:
          discussion_key: discussionKey
          from: options['from']
          per: options['per']
          reverse: options['reverse']

    minLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.min @where(discussionId: discussion.id), (event) -> event.sequenceId
      item.sequenceId || 0

    maxLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.max @where(discussionId: discussion.id), (event) -> event.sequenceId
      item.sequenceId || 0
