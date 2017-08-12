angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, $routeParams, RecordLoader, Records, Session, ThreadQueryService, AppConfig, $mdMedia, ModalService, GroupModal) ->

  $rootScope.$broadcast('currentComponent', { page: 'dashboardPage', filter: $routeParams.filter })
  $rootScope.$broadcast('setTitle', 'Recent')
  $rootScope.$broadcast('analyticsClearGroup')

  @filter = $routeParams.filter || 'hide_muted'
  filters = (filters) =>
    ['only_threads_in_my_groups', @filter].concat(filters)
  @views =
    proposals: ThreadQueryService.queryFor
      name:    'dashboardProposals'
      filters: filters('show_proposals')
    today:     ThreadQueryService.queryFor
      name:    'dashboardToday'
      from:    '1 second ago'
      to:      '-10 year ago' # into the future!
      filters: filters('hide_proposals')
    yesterday: ThreadQueryService.queryFor
      name:    'dashboardYesterday'
      from:    '1 day ago'
      to:      '1 second ago'
      filters: filters('hide_proposals')
    thisweek: ThreadQueryService.queryFor
      name:    'dashboardThisWeek'
      from:    '1 week ago'
      to:      '1 day ago'
      filters: filters('hide_proposals')
    thismonth: ThreadQueryService.queryFor
      name:    'dashboardThisMonth'
      from:    '1 month ago'
      to:      '1 week ago'
      filters: filters('hide_proposals')
    older:
      name:    'dashboardOlder'
      from:    '3 month ago'
      to:      '1 month ago'
      filters: filters('hide_proposals')

  @viewNames = _.keys(@views)
  @loadingViewNames = _.take @viewNames, 3

  @loader = new RecordLoader
    collection: 'discussions'
    action: 'dashboard'
    params:
      filter: @filter
      per: 50
  @loader.fetchRecords().then => AppConfig.dashboardLoaded = true
  @dashboardLoaded = -> AppConfig.dashboardLoaded

  @noGroups = ->
    !Session.user().hasAnyGroups()

  @noThreads = ->
    _.all @views, (view) -> !view.any()

  @startGroup = ->
    ModalService.open GroupModal, group: -> Records.groups.build()

  @userHasMuted = -> Session.user().hasExperienced("mutingThread")

  @showLargeImage = -> $mdMedia("gt-sm")

  return
