angular.module('loomioApp').controller 'RootController', ($scope, $timeout, $location, $router, $mdMedia, KeyEventService, MessageChannelService, IntercomService, ScrollService, Session, AppConfig, Records, ModalService, SignInForm, GroupForm, AbilityService, AhoyService, ViewportService, HotkeyService) ->
  $scope.isLoggedIn = AbilityService.isLoggedIn
  $scope.currentComponent = 'nothing yet'

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
    ModalService.open(GroupForm, group: -> Records.groups.build()) if $location.search().start_group?
    IntercomService.boot()
    MessageChannelService.subscribe()

  $scope.$on 'currentComponent', (event, options = {}) ->
    Session.currentGroup = options.group
    IntercomService.updateWithGroup(Session.currentGroup)

    $scope.pageError = null
    $scope.$broadcast('clearBackgroundImageUrl')
    ScrollService.scrollTo(options.scrollTo or 'h1') unless options.skipScroll
    $scope.links = options.links or {}
    if AbilityService.requireLoginFor(options.page)
      ModalService.open(SignInForm, preventClose: -> true)

  $scope.$on 'setTitle', (event, title) ->
    document.querySelector('title').text = _.trunc(title, 300) + ' | Loomio'

  $scope.$on 'pageError', (event, error) ->
    $scope.pageError = error
    if !AbilityService.isLoggedIn() and error.status == 403
      ModalService.open(SignInForm, preventClose: -> true)

  $scope.$on 'setBackgroundImageUrl', (event, group) ->
    url = group.coverUrl(ViewportService.viewportSize())
    angular.element(document.querySelector('.lmo-main-background')).attr('style', "background-image: url(#{url})")

  $scope.$on 'clearBackgroundImageUrl', (event) ->
    angular.element(document.querySelector('.lmo-main-background')).removeAttr('style')

  $scope.keyDown = (event) -> KeyEventService.broadcast(event)

  $router.config AppConfig.routes.concat AppConfig.plugins.routes


  AppConfig.records = Records
  AhoyService.init()
  Session.login(AppConfig.bootData)
  HotkeyService.init($scope) if AbilityService.isLoggedIn()

  return
