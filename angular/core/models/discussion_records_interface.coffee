angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroup: (groupKey, options = {}) ->
      options['group_id'] = groupKey
      @fetch
        params: options

    fetchDashboard: (options = {}) ->
      @fetch
        path: 'dashboard'
        params: options

    fetchInbox: (options = {}) ->
      @fetch
        path: 'inbox'
        params:
          from:          options['from'] or 0
          per:           options['per'] or 100
          since:         options['since'] or moment().startOf('day').subtract(6, 'week').toDate()
          timeframe_for: options['timeframe_for'] or 'last_activity_at'
