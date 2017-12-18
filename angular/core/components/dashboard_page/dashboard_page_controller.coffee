angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, $routeParams, RecordLoader, Records, Session, ThreadQueryService, AppConfig, $mdMedia, ModalService, GroupModal) ->

  @filter = $routeParams.filter || 'hide_muted'

  titleKey = =>
    if @filter == 'show_muted'
      'dashboard_page.filtering.muted'
    else
      'dashboard_page.filtering.all'

  $rootScope.$broadcast 'currentComponent',
    titleKey: titleKey()
    page: 'dashboardPage'
    filter: $routeParams.filter

  $rootScope.$broadcast('analyticsClearGroup')

  viewName = (name) =>
    if @filter == 'show_muted'
      "dashboard#{_.capitalize(name)}Muted"
    else
      "dashboard#{_.capitalize(name)}"

  filters = (filters) =>
    ['only_threads_in_my_groups', 'show_opened', @filter].concat(filters)

  @views =
    proposals: ThreadQueryService.queryFor
      name:    viewName("proposals")
      filters: filters('show_proposals')
    today:     ThreadQueryService.queryFor
      name:    viewName("today")
      from:    '1 second ago'
      to:      '-10 year ago' # into the future!
      filters: filters('hide_proposals')
    yesterday: ThreadQueryService.queryFor
      name:    viewName("yesterday")
      from:    '1 day ago'
      to:      '1 second ago'
      filters: filters('hide_proposals')
    thisweek: ThreadQueryService.queryFor
      name:    viewName("thisWeek")
      from:    '1 week ago'
      to:      '1 day ago'
      filters: filters('hide_proposals')
    thismonth: ThreadQueryService.queryFor
      name:    viewName("thisMonth")
      from:    '1 month ago'
      to:      '1 week ago'
      filters: filters('hide_proposals')
    older: ThreadQueryService.queryFor
      name:    viewName("older")
      from:    '3 month ago'
      to:      '1 month ago'
      filters: filters('hide_proposals')

  @viewNames = _.keys(@views)
  @loadingViewNames = _.take @viewNames, 3

  @loader = new RecordLoader
    collection: 'discussions'
    path: 'dashboard'
    params:
      filter: @filter
      per: 50
  @loader.fetchRecords().then => AppConfig.dashboardLoaded = true

  @dashboardLoaded = -> AppConfig.dashboardLoaded
  @noGroups        = -> !Session.user().hasAnyGroups()
  @noThreads       = -> _.all @views, (view) -> !view.any()
  @startGroup      = -> ModalService.open GroupModal, group: -> Records.groups.build()
  @userHasMuted    = -> Session.user().hasExperienced("mutingThread")
  @showLargeImage  = -> $mdMedia("gt-sm")

  return
