angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, Records, CurrentUser, LoadingService) ->
  $rootScope.$broadcast('currentComponent', 'dashboardPage')
  $rootScope.$broadcast('setTitle', 'Dashboard')

  @perPage = 25
  @loaded =
    show_all:           0
    show_muted:         0
    show_proposals:     0
    show_participating: 0

  @filter = -> CurrentUser.dashboardFilter

  @loadMore = =>
    from = @loaded[@filter()]
    @loaded[@filter()] = @loaded[@filter()] + @perPage
    
    Records.discussions.fetchDashboard
      filter: @filter()
      from:   from
      per:    @perPage
  LoadingService.applyLoadingFunction @, 'loadMore'

  @changePreferences = (options = {}) =>
    CurrentUser.updateFromJSON(options)
    CurrentUser.save()
    @loadMore() if @loaded[@filter()] == 0

  @dashboardDiscussionReaders = =>
    _.pluck Records.discussionReaders.forDashboard(
      muted:         @filter() == 'show_muted'
      proposals:     @filter() == 'show_proposals'
      participating: @filter() == 'show_participating').data(), 'id'

  @dashboardThreads = =>
    Records.discussions.findByDiscussionIds(@dashboardDiscussionReaders())
                       .simplesort('lastActivityAt', true)
                       .limit(@loaded[@filter()])
                       .data()

  @timeframes = ['today', 'yesterday', 'this_week', 'this_month', 'older']
  timeframe = (options = {}) =>
    today = moment().startOf 'day'
    =>
      _.filter @dashboardThreads(), (thread) ->
        thread.lastInboxActivity()
              .isBetween(today.clone().subtract(options['fromCount'] or 1, options['from']),
                         today.clone().subtract(options['toCount'] or 1, options['to']))

  @today      = timeframe(from: 'second', toCount: -10, to: 'year')
  @yesterday  = timeframe(from: 'day', to: 'second')
  @thisWeek   = timeframe(from: 'week', to: 'day')
  @thisMonth  = timeframe(from: 'month', to: 'week')
  @older      = timeframe(fromCount: 3, from: 'month', to: 'month')

  @threadsFor = (timeframe) -> @[_.camelCase(timeframe)]()
  @groupName  = (group) -> group.name

  Records.votes.fetchMyRecentVotes()
  @loadMore()

  return
