angular.module('loomioApp').controller 'RootController', ($scope, $timeout, $translate, $location, $router, $mdMedia, AuthModal, KeyEventService, MessageChannelService, IntercomService, ScrollService, Session, AppConfig, Records, ModalService, GroupModal, AbilityService, AhoyService, ViewportService, HotkeyService) ->
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
      ModalService.open GroupModal, group: ->
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
    ScrollService.scrollTo(options.scrollTo or 'h1') unless options.skipScroll
    $scope.links = options.links or {}
    $scope.forceSignIn() if AbilityService.requireLoginFor(options.page) or AppConfig.pendingIdentity?

  $scope.$on 'pageError', (event, error) ->
    $scope.pageError = error
    $scope.forceSignIn() if !AbilityService.isLoggedIn() and error.status == 403

  $scope.$on 'setBackgroundImageUrl', (event, group) ->
    url = group.coverUrl(ViewportService.viewportSize())
    angular.element(document.querySelector('.lmo-main-background')).attr('style', "background-image: url(#{url})")

  $scope.$on 'clearBackgroundImageUrl', (event) ->
    angular.element(document.querySelector('.lmo-main-background')).removeAttr('style')

  $scope.forceSignIn = ->
    return if $scope.forcedSignIn
    $scope.forcedSignIn = true
    ModalService.open AuthModal, preventClose: -> true

  $scope.keyDown = (event) -> KeyEventService.broadcast(event)

  $router.config AppConfig.routes.concat AppConfig.plugins.routes

  AppConfig.records = Records
  AhoyService.init()
  Session.login(AppConfig.bootData)
  HotkeyService.init($scope) if AbilityService.isLoggedIn()

  return
