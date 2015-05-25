angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, $scope, Records, CurrentUser, LoadingService, ThreadQueryService) ->
  $rootScope.$broadcast('currentComponent', { page: 'dashboardPage' })
  $rootScope.$broadcast('setTitle', 'Dashboard')

  Records.votes.fetchMyRecentVotes()

  @perPage = 25
  @loaded =
    show_all:           0
    show_muted:         0
    show_proposals:     0
    show_participating: 0

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

  @displayByGroup = ->
    _.contains ['show_starred', 'show_muted'], @filter

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

  @setFilter = (filter = 'show_all') =>
    @filter = filter
    @currentBaseQuery = ThreadQueryService.filterQuery(@filter)
    @refresh()
  @setFilter()
  $scope.$on 'homePageClicked', => @setFilter()

  return
