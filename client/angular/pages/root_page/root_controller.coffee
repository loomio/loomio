Routes          = require 'angular/routes.coffee'
AppConfig       = require 'shared/services/app_config.coffee'
Session         = require 'shared/services/session.coffee'
Records         = require 'shared/services/records.coffee'
EventBus        = require 'shared/services/event_bus.coffee'
AbilityService  = require 'shared/services/ability_service.coffee'
ModalService    = require 'shared/services/modal_service.coffee'
IntercomService = require 'shared/services/intercom_service.coffee'
I18n            = require 'shared/services/i18n.coffee'

{ viewportSize, scrollTo, trackEvents } = require 'shared/helpers/window.coffee'
{ signIn, subscribeToLiveUpdate }       = require 'shared/helpers/user.coffee'
{ broadcastKeyEvent, registerHotkeys }  = require 'angular/helpers/keyboard.coffee'
{ listenForEvents }                     = require 'shared/helpers/listen.coffee'
{ setupAngular }                        = require 'angular/helpers/setup.coffee'

$controller = ($scope, $rootScope, $injector, $timeout, $router, $browser) ->
  $scope.currentComponent = 'nothing yet'
  $scope.renderSidebar    = viewportSize() == 'extralarge'

  $scope.isLoggedIn       = -> AbilityService.isLoggedIn()
  $scope.isEmailVerified  = -> AbilityService.isEmailVerified()
  $scope.keyDown          = (event) -> broadcastKeyEvent($scope, event)
  $scope.forceSignIn      = ->
    return if $scope.forcedSignIn
    $scope.forcedSignIn = true
    ModalService.open 'AuthModal', preventClose: -> true
  $scope.loggedIn = ->
    $scope.pageError = null
    $scope.refreshing = true
    $timeout -> $scope.refreshing = false
    IntercomService.boot()
    subscribeToLiveUpdate()

  setupAngular($scope, $injector)

  EventBus.listen $scope, 'toggleSidebar', (event, show) ->
    return if show == false
    $scope.renderSidebar = true

  EventBus.listen $scope, 'loggedIn', $scope.loggedIn
  EventBus.listen $scope, 'logout', -> IntercomService.shutdown()

  EventBus.listen $scope, 'currentComponent', (event, options = {}) ->
    title = options.title or I18n.t(options.titleKey)
    document.querySelector('title').text = _.trunc(title, 300) + " | #{AppConfig.theme.site_name}"
    scrollTo(options.scrollTo or 'h1') unless options.skipScroll

    Session.currentGroup = options.group
    IntercomService.updateWithGroup(Session.currentGroup)

    $scope.pageError = null
    EventBus.broadcast $scope, 'clearBackgroundImageUrl'
    $scope.links = options.links or {}
    $scope.forceSignIn() if AbilityService.requireLoginFor(options.page) or AppConfig.pendingIdentity?

  EventBus.listen $scope, 'pageError', (event, error) ->
    $scope.pageError = error
    $scope.forceSignIn() if !AbilityService.isLoggedIn() and error.status == 403

  EventBus.listen $scope, 'setBackgroundImageUrl', (event, group) ->
    url = group.coverUrl(viewportSize())
    angular.element(document.querySelector('.lmo-main-background')).attr('style', "background-image: url(#{url})")

  EventBus.listen $scope, 'clearBackgroundImageUrl', (event) ->
    angular.element(document.querySelector('.lmo-main-background')).removeAttr('style')

  $router.config(Routes.concat(AppConfig.plugins.routes))

  listenForEvents($scope)
  signIn(AppConfig.bootData, AppConfig.bootData.current_user_id, $scope.loggedIn)
  registerHotkeys($scope,
    pressedI: -> ModalService.open 'InvitationModal',      group:      -> Session.currentGroup or Records.groups.build()
    pressedG: -> ModalService.open 'GroupModal',           group:      -> Records.groups.build()
    pressedT: -> ModalService.open 'DiscussionModal',      discussion: -> Records.discussions.build(groupId: (Session.currentGroup or {}).id)
    pressedP: -> ModalService.open 'PollCommonStartModal', poll:       -> Records.polls.build(authorId: Session.user().id)
  ) if AbilityService.isLoggedIn()

  Records.afterImport = -> $timeout -> $rootScope.$apply()
  Records.setRemoteCallbacks
    onPrepare: -> $browser.$$incOutstandingRequestCount()
    onCleanup: -> $browser.$$completeOutstandingRequest(->)

  return

$controller.$inject = ['$scope', '$rootScope', '$injector', '$timeout', '$router', '$browser']
angular.module('loomioApp').controller 'RootController', $controller
