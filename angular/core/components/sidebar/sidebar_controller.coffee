angular.module('loomioApp').controller 'SidebarController', ($scope, Session, $rootScope, $window, RestfulClient, $mdMedia, ThreadQueryService, UserHelpService, AppConfig, IntercomService, $mdSidenav, LmoUrlService, Records) ->
  $scope.showSidebar = $mdMedia("gt-md")
  $scope.currentState = ""

  $scope.$on 'toggleSidebar', ->
    $scope.showSidebar = !$scope.showSidebar

  $scope.$on 'currentComponent', (el, component) ->
    $scope.currentState = component

  $scope.onPage = (page, key, filter) ->
    switch page
      when 'groupPage' then $scope.currentState.key == key
      when 'dashboardPage' then $scope.currentState.page == page && $scope.currentState.filter == filter
      else $scope.currentState.page == page

  $scope.groupUrl = (group) ->
    LmoUrlService.group(group)

  $scope.signOut = ->
    Records.sessions.remote.destroy('').then -> $window.location.href = '/'

  $scope.helpLink = ->
    UserHelpService.helpLink()

  $scope.unreadThreadCount = ->
    ThreadQueryService.filterQuery(['show_unread', 'only_threads_in_my_groups'], queryType: 'inbox').length()

  $scope.showContactUs = ->
    AppConfig.isLoomioDotOrg

  $scope.contactUs = ->
    IntercomService.contactUs()

  $scope.sidebarItemSelected = ->
    if !$mdMedia("gt-md")
      $mdSidenav('left').close()

  $scope.groups = ->
    Session.user().groups()

  $scope.currentUser = ->
    Session.user()
