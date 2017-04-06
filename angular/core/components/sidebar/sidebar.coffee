angular.module('loomioApp').directive 'sidebar', ->
  scope: false
  restrict: 'E'
  templateUrl: 'generated/components/sidebar/sidebar.html'
  replace: true
  controller: ($scope, Session, $rootScope, $window, RestfulClient, ThreadQueryService, UserHelpService, AppConfig, IntercomService, $mdMedia, $mdSidenav, LmoUrlService, Records, ModalService, GroupForm, DiscussionForm, AbilityService) ->
    $scope.currentState = ""
    $scope.showSidebar = true

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

    $scope.signOut = ->
      Records.sessions.remote.destroy('').then -> $window.location.href = '/'

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.unreadThreadCount = ->
      ThreadQueryService.filterQuery(['show_unread', 'only_threads_in_my_groups'], queryType: 'inbox').length()

    $scope.showContactUs = ->
      # TODO: use loomio_org plugin to determine official site or not
      AppConfig.baseUrl == 'https://www.loomio.org/'

    $scope.contactUs = ->
      IntercomService.contactUs()

    $scope.sidebarItemSelected = ->
      if !$mdMedia("gt-md")
        $mdSidenav('left').close()

    $scope.groups = ->
      Session.user().groups().concat(Session.user().orphanParents())

    $scope.currentUser = ->
      Session.user()

    $scope.startGroup = ->
      ModalService.open GroupForm, group: -> Records.groups.build()

    $scope.startThread = ->
      ModalService.open DiscussionForm, discussion: -> Records.discussions.build(groupId: $scope.currentGroup().id)
