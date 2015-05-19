angular.module('loomioApp').factory 'EventRecordsInterface', (BaseRecordsInterface, EventModel) ->
  class EventRecordsInterface extends BaseRecordsInterface
    model: EventModel

    fetchByDiscussion: (discussionKey, options = {}) ->
      @fetch
        params:
          discussion_key: discussionKey
          from: options['from']
          per: options['per']

    minLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.min @find(discussionId: discussion.id), (event) -> event.sequenceId or Number.MAX_VALUE
      item.sequenceId

    maxLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.max @find(discussionId: discussion.id), (event) -> event.sequenceId or 0
      item.sequenceId
