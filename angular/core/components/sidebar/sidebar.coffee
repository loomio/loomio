angular.module('loomioApp').directive 'sidebar', ($rootScope, $mdMedia, $mdSidenav, $window, Session, InboxService, RestfulClient, UserHelpService, AppConfig, IntercomService, LmoUrlService, Records, ModalService, GroupModal, DiscussionModal, AbilityService)->
  scope: false
  restrict: 'E'
  templateUrl: 'generated/components/sidebar/sidebar.html'
  replace: true
  controller: ($scope) ->
    $scope.currentState = ""
    $scope.showSidebar = true
    InboxService.load()

    $scope.hasAnyGroups = ->
      Session.user().hasAnyGroups()

    availableGroups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.currentGroup = ->
      return _.first(availableGroups()) if availableGroups().length == 1
      _.find(availableGroups(), (g) -> g.id == Session.currentGroupId()) || Records.groups.build()

    $scope.$on 'toggleSidebar', (event, show) ->
      if !_.isUndefined(show)
        $scope.showSidebar = show
      else
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

    $scope.unreadThreadCount = ->
      InboxService.unreadCount()

    $scope.sidebarItemSelected = ->
      if !$mdMedia("gt-md")
        $mdSidenav('left').close()

    $scope.groups = ->
      Session.user().groups().concat(Session.user().orphanParents())

    $scope.currentUser = ->
      Session.user()

    $scope.canStartGroup = -> AbilityService.canStartGroups()
    $scope.canViewPublicGroups = -> AbilityService.canViewPublicGroups()

    $scope.startGroup = ->
      ModalService.open GroupModal, group: -> Records.groups.build()

    $scope.startThread = ->
      ModalService.open DiscussionModal, discussion: -> Records.discussions.build(groupId: $scope.currentGroup().id)
