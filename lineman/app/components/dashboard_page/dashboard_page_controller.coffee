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

  @timeframes =
    today:     { from: '1 second ago', to: '-10 year ago' }
    yesterday: { from: '1 day ago',    to: '1 second ago' }
    thisweek:  { from: '1 week ago',   to: '1 day ago' }
    thismonth: { from: '1 month ago',  to: '1 week ago' }
    older:     { from: '3 month ago',  to: '1 month ago' }
  @timeframeNames = _.map @timeframes, (timeframe, name) -> name
  @timeframeQueryFor = (name) -> @timeframes[name].view

  @groups = {}
  @groupThreadLimit = 5
  @groups = -> CurrentUser.parentGroups()
  @groupName = (group) -> group.name
  @groupQueryFor = (group) -> @groups[group.key]
  @moreForThisGroup = (group) -> @groupQueryFor(group, { filter: @filter }).length() > @groupThreadLimit

  @updateQueries = ->
    _.each @groups(), (group) =>
      @groups[group.key] = ThreadQueryService.groupQuery(group, { filter: @filter })
    _.each @timeframeNames, (name) =>
      @timeframes[name].view = ThreadQueryService.timeframeQuery
        name: name
        filter: @filter
        timeframe: @timeframes[name]

  @loadMore = =>
    from = @loaded[@filter]
    @loaded[@filter] = @loaded[@filter] + @perPage

    Records.discussions.fetchDashboard
      filter: @filter
      from:   from
      per:    @perPage
  LoadingService.applyLoadingFunction @, 'loadMore'

  @refresh = ->
    @updateQueries()
    @loadMore() if @loaded[@filter] == 0

  @setFilter = (filter) ->
    @filter = filter
    @refresh()
  @setFilter 'show_all'


  return
