angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, Records, CurrentUser, LoadingService) ->
  $rootScope.$broadcast('currentComponent', 'dashboardPage')
  $rootScope.$broadcast('setTitle', 'Dashboard')

  @loaded = {}
  @perPage = 25

  @filter = -> CurrentUser.dashboardFilter

  @loadedCount = =>
    @loaded[@filter()] = @loaded[@filter()] or 0

  @updateLoadedCount = =>
    current = @loadedCount()
    @loaded[@filter()] = current + @perPage

  @loadParams = ->
    filter: @filter()
    per:    @perPage
    from:   @loadedCount()

  @loadMore = =>
    params = @loadParams()
    @updateLoadedCount()
    Records.discussions.fetchDashboard(params)
  LoadingService.applyLoadingFunction @, 'loadMore'

  @changePreferences = (options = {}) =>
    CurrentUser.updateFromJSON(options)
    CurrentUser.save()
    @loadMore() if @loadedCount() == 0

  @dashboardOptions = =>
    muted:         @filter() == 'show_muted'
    unread:        @filter() == 'show_unread'
    proposals:     @filter() == 'show_proposals'
    participating: @filter() == 'show_participating'

  @dashboardDiscussionReaders = =>
    _.pluck Records.discussionReaders.forDashboard(@dashboardOptions()).data(), 'id'

  @dashboardThreads = =>
    Records.discussions.findByDiscussionIds(@dashboardDiscussionReaders())
                       .simplesort('lastActivityAt', true)
                       .limit(@loadedCount())
                       .data()

  @discussionsFor = (timeframe) => @[_.camelCase(timeframe)]()
  @timeframes = ['today', 'yesterday', 'this_week', 'this_month', 'older']

  timeframe = (options = {}) =>
    today = moment().startOf 'day'
    =>
      _.filter @dashboardThreads(), (thread) ->
        thread.lastInboxActivity()
              .isBetween(today.clone().subtract(options['fromCount'] or 1, options['from']),
                         today.clone().subtract(options['toCount'] or 1, options['to']))

  @today     = timeframe(from: 'second', toCount: -10, to: 'year')
  @yesterday = timeframe(from: 'day', to: 'second')
  @thisWeek  = timeframe(from: 'week', to: 'day')
  @thisMonth = timeframe(from: 'month', to: 'week')
  @older     = timeframe(fromCount: 3, from: 'month', to: 'month')

  @groupName = (group) -> group.name

  Records.votes.fetchMyRecentVotes()
  @loadMore()

  return
