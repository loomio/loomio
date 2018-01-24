AppConfig       = require 'shared/services/app_config.coffee'
Session         = require 'shared/services/session.coffee'
Records         = require 'shared/services/records.coffee'
EventBus        = require 'shared/services/event_bus.coffee'
AbilityService  = require 'shared/services/ability_service.coffee'
ModalService    = require 'shared/services/modal_service.coffee'
IntercomService = require 'shared/services/intercom_service.coffee'

{ scrollTo, setCurrentComponent, performFlash } = require 'shared/helpers/layout.coffee'
{ viewportSize, trackEvents }                   = require 'shared/helpers/window.coffee'
{ signIn, subscribeToLiveUpdate }               = require 'shared/helpers/user.coffee'
{ broadcastKeyEvent, registerHotkeys }          = require 'shared/helpers/keyboard.coffee'
{ setupAngular }                                = require 'angular/setup.coffee'

$controller = ($scope, $injector) ->
  $scope.theme  = AppConfig.theme
  $scope.assets = AppConfig.assets
  setupAngular($scope, $injector)

  Records.boot.remote.get('user').then (response) ->
    signIn(response, response.current_user_id, $scope.loggedIn)
    performFlash(response)

  $scope.currentComponent = 'nothing yet'
  $scope.renderSidebar    = viewportSize() == 'extralarge'
  $scope.isLoggedIn       = -> AbilityService.isLoggedIn()
  $scope.isEmailVerified  = -> AbilityService.isEmailVerified()
  $scope.keyDown          = (event) -> broadcastKeyEvent($scope, event)
  $scope.loggedIn = ->
    $scope.pageError = null
    $scope.refreshing = true
    $injector.get('$timeout') -> $scope.refreshing = false
    IntercomService.fetch()
    IntercomService.boot()
    subscribeToLiveUpdate()

  EventBus.listen $scope, 'toggleSidebar',    -> $scope.renderSidebar = true
  EventBus.listen $scope, 'loggedIn',         -> $scope.loggedIn()
  EventBus.listen $scope, 'pageError', (_, error) ->
    $scope.pageError = error
    ModalService.forceSignIn() if !AbilityService.isLoggedIn() and error.status == 403
  EventBus.listen $scope, 'currentComponent', (_, options) ->
    $scope.pageError = null
    $scope.links = options.links or {}
    setCurrentComponent(options)

  return

$controller.$inject = ['$scope', '$injector']
angular.module('loomioApp').controller 'RootController', $controller
