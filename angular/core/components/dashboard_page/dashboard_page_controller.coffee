angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, $scope, RecordLoader, Records, Session, LoadingService, ThreadQueryService, AbilityService, AppConfig, $routeParams, $mdMedia, ModalService, GroupModal) ->

  $rootScope.$broadcast('currentComponent', { page: 'dashboardPage', filter: $routeParams.filter })
  $rootScope.$broadcast('setTitle', 'Recent')
  $rootScope.$broadcast('analyticsClearGroup')

  AppConfig.dashboardLoaded = false
  @dashboardLoaded = -> AppConfig.dashboardLoaded

  @timeframes =
    today:     { from: '1 second ago', to: '-10 year ago' } # into the future!
    yesterday: { from: '1 day ago',    to: '1 second ago' }
    thisweek:  { from: '1 week ago',   to: '1 day ago' }
    thismonth: { from: '1 month ago',  to: '1 week ago' }
    older:     { from: '3 month ago',  to: '1 month ago' }

  @views = {}
  @viewNames = ['proposals'].concat(_.keys(@timeframes))
  @loadingViewNames = _.take @viewNames, 3

  @filter = $routeParams.filter || 'hide_muted'
  @loader = new RecordLoader
    collection: 'discussions'
    action: 'dashboard'
    params:
      filter: @filter
      per: 50
  @loader.fetchRecords().then => @initialLoad = false

  @loadMore = ->
    @loader.fetchRecords().then =>
      AppConfig.dashboardLoaded = true
      @views.proposals = ThreadQueryService.queryFor(filters: [
        'only_threads_in_my_groups',
        'show_proposals',
        @filter
      ])

      _.each _.keys(@timeframes), (name) =>
        @views[name] = ThreadQueryService.queryFor
          name: name
          filters: ['only_threads_in_my_groups', 'hide_proposals', @filter]
          from: @timeframes[name].from
          to:   @timeframes[name].to
  @loadMore()

  @noGroups = ->
    !Session.user().hasAnyGroups()

  @noThreads = ->
    _.all @views, (view) -> !view.any()

  @startGroup = ->
    ModalService.open GroupModal, group: -> Records.groups.build()

  @userHasMuted = -> Session.user().hasExperienced("mutingThread")

  @showLargeImage = -> $mdMedia("gt-sm")

  return
