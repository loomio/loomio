AppConfig       = require 'shared/services/app_config'
EventBus        = require 'shared/services/event_bus'
AbilityService  = require 'shared/services/ability_service'
LmoUrlService   = require 'shared/services/lmo_url_service'
ModalService    = require 'shared/services/modal_service'
IntercomService = require 'shared/services/intercom_service'

{ signIn }                                       = require 'shared/helpers/user'
{ viewportSize, trackEvents, deprecatedBrowser } = require 'shared/helpers/window'
{ broadcastKeyEvent, registerHotkeys }           = require 'shared/helpers/keyboard'
{ scrollTo, setCurrentComponent }                = require 'shared/helpers/layout'
{ initLiveUpdate }                               = require 'shared/helpers/cable'
{ setupAngular }                                 = require 'angular/setup'

$controller = ($scope, $injector) ->
  setupAngular($scope, $injector)

  $scope.warnDeprecation  = deprecatedBrowser()
  $scope.currentComponent = 'nothing yet'
  $scope.renderSidebar    = viewportSize() == 'extralarge'
  $scope.isLoggedIn       = -> AbilityService.isLoggedIn()
  $scope.isEmailVerified  = -> AbilityService.isEmailVerified()
  $scope.keyDown          = (event) -> broadcastKeyEvent($scope, event)
  $scope.loggedIn = ->
    $scope.pageError = null
    $scope.refreshing = true
    $injector.get('$timeout') -> $scope.refreshing = false
    IntercomService.boot()
    if LmoUrlService.params().set_password
      delete LmoUrlService.params().set_password
      ModalService.open 'ChangePasswordForm'

  EventBus.listen $scope, 'toggleSidebar',    -> $scope.renderSidebar = true
  EventBus.listen $scope, 'loggedIn',         -> $scope.loggedIn()
  EventBus.listen $scope, 'pageError', (_, error) ->
    $scope.pageError = error
    ModalService.forceSignIn() if !AbilityService.isLoggedIn() and error.status == 403
  EventBus.listen $scope, 'currentComponent', (_, options) ->
    $scope.pageError = null
    $scope.links = options.links or {}
    setCurrentComponent(options)

  signIn(AppConfig.bootData, AppConfig.bootData.current_user_id, $scope.loggedIn)
  initLiveUpdate()

  return

$controller.$inject = ['$scope', '$injector']
angular.module('loomioApp').controller 'RootController', $controller
