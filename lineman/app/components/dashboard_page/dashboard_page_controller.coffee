angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, Records, CurrentUser, LoadingService, ThreadQueryService) ->
  $rootScope.$broadcast('currentComponent', 'dashboardPage')
  $rootScope.$broadcast('setTitle', 'Dashboard')

  Records.votes.fetchMyRecentVotes()

  @perPage = 25
  @loaded =
    show_all:           0
    show_muted:         0
    show_proposals:     0
    show_participating: 0
  @filter    = -> CurrentUser.dashboardFilter
  @nowLoaded = -> @loaded[@filter()]

  @timeframes =
    today:     { from: '1 second ago', to: '-10 year ago' }
    yesterday: { from: '1 day ago',    to: '1 second ago' }
    thisweek:  { from: '1 week ago',   to: '1 day ago' }
    thismonth: { from: '1 month ago',  to: '1 week ago' }
    older:     { from: '3 month ago',  to: '1 month ago' }
  @timeframeNames = _.map @timeframes, (timeframe, name) -> name
  @timeframeFor = (name) -> @timeframes[name].view

  @updateTimeframes = ->
    # set timeframes.today.view, timeframes.yesterday.view, etc.
    _.each @timeframeNames, (name) =>
      @timeframes[name].view = ThreadQueryService.timeframeQuery
        name: name
        filter: CurrentUser.dashboardFilter
        timeframe: @timeframes[name]
  @updateTimeframes()

  @loadMore = =>
    from = @nowLoaded()
    @loaded[CurrentUser.dashboardFilter] = @nowLoaded() + @perPage

    Records.discussions.fetchDashboard
      filter: CurrentUser.dashboardFilter
      from:   from
      per:    @perPage
  LoadingService.applyLoadingFunction @, 'loadMore'
  @loadMore()

  @changePreferences = (options = {}) =>
    CurrentUser.updateFromJSON(options)
    CurrentUser.save()
    @updateTimeframes()
    @loadMore() if @nowLoaded() == 0

  return
