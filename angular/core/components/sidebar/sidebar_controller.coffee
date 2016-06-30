angular.module('loomioApp').controller 'SidebarController', ($scope, Session, $rootScope, $window, RestfulClient, $mdMedia, ThreadQueryService, UserHelpService, AppConfig, IntercomService, $mdSidenav) ->
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

  $scope.groups = ->
    Session.user().groups()

  $scope.groupUrl = (group) ->
    name = group.fullName.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()
    "/g/#{group.key}/#{name}"

  $scope.signOut = ->
    $rootScope.$broadcast 'logout'
    @sessionClient = new RestfulClient('sessions')
    @sessionClient.destroy('').then ->
    $window.location = '/'

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

  $scope.parentGroups = =>
    _.unique _.compact _.map Session.user().memberships(), (membership) =>
      if membership.group().isParent()
        membership.group()
      else if !Session.user().isMemberOf(membership.group().parent())
        membership.group().parent()

