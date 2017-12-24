Routes         = require 'angular/routes.coffee'
AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ viewportSize, scrollTo, trackEvents }  = require 'angular/helpers/window.coffee'
{ signIn, setLocale }                    = require 'angular/helpers/user.coffee'
{ broadcastKeyEvent, registerHotkeys }   = require 'angular/helpers/keyboard.coffee'
{ setupAngularModal, setupAngularFlash } = require 'angular/helpers/setup.coffee'

angular.module('loomioApp').controller 'RootController', ($scope, $injector, $timeout, $translate, $mdDialog, $location, $router, MessageChannelService, IntercomService) ->

  $scope.currentComponent = 'nothing yet'
  $scope.renderSidebar    = viewportSize() == 'extralarge'

  $scope.isLoggedIn       = -> AbilityService.isLoggedIn()
  $scope.isEmailVerified  = -> AbilityService.isEmailVerified()
  $scope.keyDown          = (event) -> broadcastKeyEvent($scope, event)
  $scope.forceSignIn      = ->
    return if $scope.forcedSignIn
    $scope.forcedSignIn = true
    ModalService.open 'AuthModal', preventClose: -> true

  $translate.onReady -> $scope.translationsLoaded = true

  $scope.$on 'toggleSidebar', (event, show) ->
    return if show == false
    $scope.renderSidebar = true

  $scope.$on 'loggedIn', (event, user) ->
    $scope.pageError = null
    $scope.refreshing = true
    $timeout -> $scope.refreshing = false
    # IntercomService.boot()
    # MessageChannelService.subscribe()

  $scope.$on 'currentComponent', (event, options = {}) ->
    title = options.title or $translate.instant(options.titleKey)
    document.querySelector('title').text = _.trunc(title, 300) + " | #{AppConfig.theme.site_name}"
    scrollTo(options.scrollTo or 'h1') unless options.skipScroll

    Session.currentGroup = options.group
    # IntercomService.updateWithGroup(Session.currentGroup)

    $scope.pageError = null
    $scope.$broadcast('clearBackgroundImageUrl')
    $scope.links = options.links or {}
    $scope.forceSignIn() if AbilityService.requireLoginFor(options.page) or AppConfig.pendingIdentity?

  $scope.$on 'pageError', (event, error) ->
    $scope.pageError = error
    $scope.forceSignIn() if !AbilityService.isLoggedIn() and error.status == 403

  $scope.$on 'setBackgroundImageUrl', (event, group) ->
    url = group.coverUrl(viewportSize())
    angular.element(document.querySelector('.lmo-main-background')).attr('style', "background-image: url(#{url})")

  $scope.$on 'clearBackgroundImageUrl', (event) ->
    angular.element(document.querySelector('.lmo-main-background')).removeAttr('style')

  $router.config(Routes.concat(AppConfig.plugins.routes))

  setupAngularModal($scope, $injector, $translate, $mdDialog)
  setupAngularFlash($scope)
  trackEvents($scope)
  signIn(AppConfig.bootData, $location, $scope)
  setLocale($translate)
  registerHotkeys($scope,
    pressedI: -> ModalService.open 'InvitationModal',      group:      -> Session.currentGroup or Records.groups.build()
    pressedG: -> ModalService.open 'GroupModal',           group:      -> Records.groups.build()
    pressedT: -> ModalService.open 'DiscussionModal',      discussion: -> Records.discussions.build(groupId: (Session.currentGroup or {}).id)
    pressedP: -> ModalService.open 'PollCommonStartModal', poll:       -> Records.polls.build(authorId: Session.user().id)
  ) if AbilityService.isLoggedIn()

  Records.afterImport = -> $scope.$apply()

  return
