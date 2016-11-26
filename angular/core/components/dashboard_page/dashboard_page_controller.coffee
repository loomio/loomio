angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, $scope, Records, Session, LoadingService, ThreadQueryService, AbilityService, AppConfig, $routeParams, $mdMedia, ModalService, GroupForm) ->

  $rootScope.$broadcast('currentComponent', { page: 'dashboardPage', filter: $routeParams.filter })
  $rootScope.$broadcast('setTitle', 'Recent')
  $rootScope.$broadcast('analyticsClearGroup')

  @userHasMuted    = -> Session.user().hasExperienced("mutingThread")

  @perPage = 50
  @loaded =
    show_all:           0
    show_muted:         0

  @views =
    recent: {}
    groups: {}

  @loading = -> !AppConfig.dashboardLoaded

  @timeframes =
    today:     { from: '1 second ago', to: '-10 year ago' } # into the future!
    yesterday: { from: '1 day ago',    to: '1 second ago' }
    thisweek:  { from: '1 week ago',   to: '1 day ago' }
    thismonth: { from: '1 month ago',  to: '1 week ago' }
    older:     { from: '3 month ago',  to: '1 month ago' }
  @timeframeNames = _.map @timeframes, (timeframe, name) -> name

  @loadingViewNames = ['proposals', 'today', 'yesterday']
  @recentViewNames = ['proposals', 'starred', 'today', 'yesterday', 'thisweek', 'thismonth', 'older']

  @groupThreadLimit = 5
  @groups = -> Session.user().parentGroups()
  @moreForThisGroup = (group) -> @views.groups[group.key].length() > @groupThreadLimit

  @displayByGroup = ->
    _.contains ['show_muted'], @filter

  @updateQueries = =>
    AppConfig.dashboardLoaded = true if @loaded[@filter] > 0
    @currentBaseQuery = ThreadQueryService.filterQuery(['only_threads_in_my_groups', @filter])
    if @displayByGroup()
      _.each @groups(), (group) =>
        @views.groups[group.key] = ThreadQueryService.groupQuery(group, { filter: @filter, queryType: 'all' })
    else
      @views.recent.proposals = ThreadQueryService.filterQuery ['only_threads_in_my_groups', 'show_not_muted', 'show_proposals', @filter], queryType: 'important'
      @views.recent.starred   = ThreadQueryService.filterQuery ['show_not_muted', 'show_starred', 'hide_proposals', @filter], queryType: 'important'
      _.each @timeframeNames, (name) =>
        @views.recent[name] = ThreadQueryService.timeframeQuery
          name: name
          filter: ['only_threads_in_my_groups', 'show_not_muted', @filter]
          timeframe: @timeframes[name]

  @loadMore = =>
    from = @loaded[@filter]
    @loaded[@filter] = @loaded[@filter] + @perPage

    Records.discussions.fetchDashboard(
      filter: @filter
      from:   from
      per:    @perPage).then @updateQueries
  LoadingService.applyLoadingFunction @, 'loadMore'

  @setFilter = (filter = 'show_all') =>
    @filter = filter
    @updateQueries()
    @loadMore() if @loaded[@filter] == 0
  @setFilter($routeParams.filter || 'show_all')

  @noGroups = ->
    !Session.user().hasAnyGroups()

  @startGroup = ->
    ModalService.open GroupForm, group: -> Records.groups.build()

  $scope.$on 'currentUserMembershipsLoaded', => @setFilter()

  @showLargeImage = -> $mdMedia("gt-sm")

  return
