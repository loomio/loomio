Routes          = require 'angular/routes.coffee'
AppConfig       = require 'shared/services/app_config.coffee'
Session         = require 'shared/services/session.coffee'
Records         = require 'shared/services/records.coffee'
EventBus        = require 'shared/services/event_bus.coffee'
AbilityService  = require 'shared/services/ability_service.coffee'
ModalService    = require 'shared/services/modal_service.coffee'
IntercomService = require 'shared/services/intercom_service.coffee'
I18n            = require 'shared/services/i18n.coffee'

{ viewportSize, scrollTo, trackEvents, updateCover } = require 'shared/helpers/window.coffee'
{ signIn, subscribeToLiveUpdate }      = require 'shared/helpers/user.coffee'
{ broadcastKeyEvent, registerHotkeys } = require 'shared/helpers/keyboard.coffee'
{ setupAngular }                       = require 'angular/setup.coffee'

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
    title = _.trunc options.title or I18n.t(options.titleKey), 300
    document.querySelector('title').text = [title, AppConfig.theme.site_name].join(' | ')

    AppConfig.currentGroup = options.group

    scrollTo(options.scrollTo or 'h1') unless options.skipScroll
    updateCover()

    IntercomService.updateWithGroup(AppConfig.currentGroup)

    $scope.pageError = null
    $scope.links = options.links or {}
    $scope.forceSignIn() if AbilityService.requireLoginFor(options.page) or AppConfig.pendingIdentity?

  EventBus.listen $scope, 'pageError', (event, error) ->
    $scope.pageError = error
    $scope.forceSignIn() if !AbilityService.isLoggedIn() and error.status == 403

  EventBus.listen $scope, 'updateCoverPhoto', updateCover

  signIn(AppConfig.bootData, AppConfig.bootData.current_user_id, $scope.loggedIn)

  return

$controller.$inject = ['$scope', '$injector']
angular.module('loomioApp').controller 'RootController', $controller
