AppConfig          = require 'shared/services/app_config.coffee'
Records            = require 'shared/services/records.coffee'
Session            = require 'shared/services/session.coffee'
EventBus           = require 'shared/services/event_bus.coffee'
RecordLoader       = require 'shared/services/record_loader.coffee'
ThreadQueryService = require 'shared/services/thread_query_service.coffee'
ModalService       = require 'shared/services/modal_service.coffee'

$controller = ($rootScope, $routeParams, $mdMedia) ->

  @filter = $routeParams.filter || 'hide_muted'

  titleKey = =>
    if @filter == 'show_muted'
      'dashboard_page.filtering.muted'
    else
      'dashboard_page.filtering.all'

  EventBus.broadcast $rootScope, 'currentComponent',
    titleKey: titleKey()
    page: 'dashboardPage'
    filter: $routeParams.filter

  EventBus.broadcast $rootScope, 'analyticsClearGroup'

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
  @loader.fetchRecords().then => @dashboardLoaded = true

  @noGroups        = -> !Session.user().hasAnyGroups()
  @noThreads       = -> _.all @views, (view) -> !view.any()
  @startGroup      = -> ModalService.open 'GroupModal', group: -> Records.groups.build()
  @userHasMuted    = -> Session.user().hasExperienced("mutingThread")
  @showLargeImage  = -> $mdMedia("gt-sm")

  return

$controller.$inject = ['$rootScope', '$routeParams', '$mdMedia']
angular.module('loomioApp').controller 'DashboardPageController', $controller
