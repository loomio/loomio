angular.module('loomioApp').factory 'EventRecordsInterface', (BaseRecordsInterface, EventModel) ->
  class EventRecordsInterface extends BaseRecordsInterface
    model: EventModel

    fetchDashboardByDate: (options = {}) ->
      @restfulClient.get 'dashboard_by_date', options

    fetchDashboardByGroup: (options = {}) ->
      @restfulClient.get 'dashboard_by_group', options

    minLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.min @where(discussionId: discussion.id), (event) -> event.sequenceId
      item.sequenceId || 0

    maxLoadedSequenceIdByDiscussion: (discussion) ->
      item = _.max @where(discussionId: discussion.id), (event) -> event.sequenceId
      item.sequenceId || 0
