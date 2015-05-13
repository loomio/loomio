angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroup: (options = {}) ->
      @fetch
        params:
          group_id: options['group_id']
          from: options['from']
          per: options['per']

    fetchDashboard: (options = {}) ->
      @fetch
        path: 'dashboard'
        params: options
        cacheKey: dashboardCacheKeyFor(options)

    dashboardCacheKeyFor = (options) ->
      "#{options['filter']}Dashboard" unless options['filter'] == 'show_all'

    fetchInbox: ->
      @fetchDashboard
        filter: 'show_unread'
        from: 0
        per: 100
        since: moment().startOf('day').subtract(3, 'month').toDate()
        timeframe_for: 'last_activity_at'
