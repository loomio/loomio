AppConfig         = require 'shared/services/app_config'
Session           = require 'shared/services/session'
Records           = require 'shared/services/records'
EventBus          = require 'shared/services/event_bus'
AbilityService    = require 'shared/services/ability_service'
LmoUrlService     = require 'shared/services/lmo_url_service'
ModalService      = require 'shared/services/modal_service'
PaginationService = require 'shared/services/pagination_service'

{ subscribeTo } = require 'shared/helpers/cable'

$controller = ($rootScope, $routeParams) ->
  EventBus.broadcast $rootScope, 'currentComponent', {page: 'groupPage', key: $routeParams.key, skipScroll: true }

  @launchers = []
  @addLauncher = (action, condition = (-> true), opts = {}) =>
    @launchers.push
      priority:       opts.priority || 9999
      action:         action
      condition:      condition
      allowContinue:  opts.allowContinue

  @addLauncher =>
    ModalService.open 'InstallSlackModal',
      group: => @group
      requirePaidPlan: -> true
  , ->
    LmoUrlService.params().install_slack

  @performLaunch = ->
    @launchers.sort((a, b) -> a.priority - b.priority).map (launcher) =>
      return if (typeof launcher.action != 'function') || @launched
      if launcher.condition()
        launcher.action()
        @launched = true unless launcher.allowContinue

  # allow for chargify reference, which comes back #{groupKey}|#{timestamp}
  # we include the timestamp so chargify sees unique values
  $routeParams.key = $routeParams.handle || $routeParams.key.split('-')[0]
  Records.groups.findOrFetch($routeParams.key, {}, true).then (group) =>
    @init(group)
  , (error) ->
    EventBus.broadcast $rootScope, 'pageError', error

  @init = (group) =>
    @group = group
    subscribeTo(@group)

    Records.drafts.fetchFor(@group) if AbilityService.canCreateContentFor(@group)

    maxDiscussions = if AbilityService.canViewPrivateContent(@group)
      @group.discussionsCount
    else
      @group.publicDiscussionsCount
    @pageWindow = PaginationService.windowFor
      current:  parseInt(LmoUrlService.params().from or 0)
      min:      0
      max:      maxDiscussions
      pageType: 'groupThreads'

    EventBus.broadcast $rootScope, 'currentComponent',
      title: @group.fullName
      page: 'groupPage'
      group: @group
      key: @group.key
      links:
        canonical:   LmoUrlService.group(@group, {}, absolute: true)
        rss:         LmoUrlService.group(@group, {}, absolute: true, ext: 'xml') if !@group.privacyIsSecret()
        prev:        LmoUrlService.group(@group, from: @pageWindow.prev)         if @pageWindow.prev?
        next:        LmoUrlService.group(@group, from: @pageWindow.next)         if @pageWindow.next?

    @performLaunch()

  return

$controller.$inject = ['$rootScope', '$routeParams']
angular.module('loomioApp').controller 'GroupPageController', $controller
