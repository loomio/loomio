AppConfig       = require 'shared/services/app_config'
EventBus        = require 'shared/services/event_bus'
AbilityService  = require 'shared/services/ability_service'
LmoUrlService   = require 'shared/services/lmo_url_service'
ModalService    = require 'shared/services/modal_service'
FlashService    = require 'shared/services/flash_service'

{ signIn }                                       = require 'shared/helpers/user'
{ viewportSize, trackEvents, deprecatedBrowser } = require 'shared/helpers/window'
{ broadcastKeyEvent, registerHotkeys }           = require 'shared/helpers/keyboard'
{ scrollTo, setCurrentComponent }                = require 'shared/helpers/layout'
{ initLiveUpdate }                               = require 'shared/helpers/cable'
{ setupAngular }                                 = require 'angular/setup'

$controller = ($scope, $injector) ->
  $scope.theme  = AppConfig.theme
  $scope.assets = AppConfig.assets
  setupAngular($scope, $injector)

  $scope.warnDeprecation  = deprecatedBrowser()
  $scope.currentComponent = 'nothing yet'
  $scope.renderSidebar    = _.includes(['large', 'extralarge'], viewportSize())
  $scope.isLoggedIn       = -> AbilityService.isLoggedIn()
  $scope.isEmailVerified  = -> AbilityService.isEmailVerified()
  $scope.keyDown          = (event) -> broadcastKeyEvent($scope, event)
  $scope.loggedIn = ->
    $scope.pageError = null
    $scope.refreshing = true
    $injector.get('$timeout') ->
      $scope.refreshing = false
      FlashService.success AppConfig.userPayload.flash.notice
      delete AppConfig.userPayload.flash.notice
    if LmoUrlService.params().set_password
      delete LmoUrlService.params().set_password
      ModalService.open 'ChangePasswordForm'

  EventBus.listen $scope, 'toggleSidebar',   (event, show) ->
    return if show == false
    $scope.renderSidebar = true
    EventBus.deafen $scope, 'toggleSidebar'

  EventBus.listen $scope, 'loggedIn',         -> $scope.loggedIn()
  EventBus.listen $scope, 'pageError', (_, error) ->
    $scope.pageError = error
    ModalService.forceSignIn() if !AbilityService.isLoggedIn() and error.status == 403
  EventBus.listen $scope, 'currentComponent', (_, options) ->
    $scope.pageError = null
    $scope.links = options.links or {}
    setCurrentComponent(options)

  signIn(AppConfig.userPayload, AppConfig.userPayload.current_user_id, $scope.loggedIn)
  initLiveUpdate()

  return

$controller.$inject = ['$scope', '$injector']
angular.module('loomioApp').controller 'RootController', $controller
