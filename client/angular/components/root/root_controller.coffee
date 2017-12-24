Routes         = require 'angular/routes.coffee'
AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
FlashService   = require 'shared/services/flash_service.coffee'

{ viewportSize, scrollTo, trackEvents } = require 'angular/helpers/window.coffee'
{ signIn, setLocale }  = require 'angular/helpers/user.coffee'
{ broadcastKeyEvent, registerHotkeys }  = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').controller 'RootController', ($scope, $timeout, $translate, $location, $router, $mdMedia, MessageChannelService, IntercomService, ModalService) ->
  $scope.isLoggedIn = ->
    AbilityService.isLoggedIn()
  $scope.isEmailVerified = ->
    AbilityService.isEmailVerified()
  $scope.currentComponent = 'nothing yet'

  $translate.onReady -> $scope.translationsLoaded = true

  # NB: $scope.refresh triggers the ng-if for the ng-outlet in the layout.
  # This means that we re-initialize the controller for the page, which is what we want
  # for actions like logging in or out, without refreshing the whole app.
  $scope.refresh = ->
    $scope.pageError = null
    $scope.refreshing = true
    $timeout -> $scope.refreshing = false

  $scope.renderSidebar = $mdMedia('gt-md')
  $scope.$on 'toggleSidebar', (event, show) ->
    return if show == false
    $scope.renderSidebar = true

  $scope.$on 'loggedIn', (event, user) ->
    $scope.refresh()
    if $location.search().start_group?
      ModalService.open 'GroupModal', group: ->
        Records.groups.build
          customFields:
            pending_emails: $location.search().pending_emails
    IntercomService.boot()
    MessageChannelService.subscribe()

  setTitle = (title) ->
    document.querySelector('title').text = _.trunc(title, 300) + " | #{AppConfig.theme.site_name}"
    Session.pageTitle = title

  $scope.$on 'currentComponent', (event, options = {}) ->
    setTitle(options.title or $translate.instant(options.titleKey))
    Session.currentGroup = options.group
    IntercomService.updateWithGroup(Session.currentGroup)

    $scope.pageError = null
    $scope.$broadcast('clearBackgroundImageUrl')
    scrollTo(options.scrollTo or 'h1') unless options.skipScroll
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

  $scope.forceSignIn = ->
    return if $scope.forcedSignIn
    $scope.forcedSignIn = true
    ModalService.open 'AuthModal', preventClose: -> true

  $scope.keyDown = (event) -> broadcastKeyEvent($scope, event)

  $router.config(Routes.concat(AppConfig.plugins.routes))

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
  FlashService.setBroadcastMethod $scope.$broadcast

  return
