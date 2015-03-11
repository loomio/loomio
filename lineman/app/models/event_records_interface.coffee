angular.module('loomioApp').factory 'EventRecordsInterface', (BaseRecordsInterface, EventModel) ->
  class EventRecordsInterface extends BaseRecordsInterface
    model: EventModel

    minLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.min @where(discussionId: discussion.id), (event) -> event.sequenceId
      item.sequenceId || 0

    maxLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.max @where(discussionId: discussion.id), (event) -> event.sequenceId
      item.sequenceId || 0
