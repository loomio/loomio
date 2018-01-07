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
{ broadcastKeyEvent, registerHotkeys }  = require 'shared/helpers/keyboard.coffee'
{ setupAngular }                        = require 'angular/setup.coffee'

$controller = ($scope, $injector) ->
  $injector.get('$router').config(Routes.concat(AppConfig.plugins.routes))

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
    $injector.get('$timeout') -> $scope.refreshing = false
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

  signIn(AppConfig.bootData, AppConfig.bootData.current_user_id, $scope.loggedIn)

  return

$controller.$inject = ['$scope', '$injector']
angular.module('loomioApp').controller 'RootController', $controller
