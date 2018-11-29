AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
InboxService   = require 'shared/services/inbox_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'sidebar', ['$mdMedia', '$mdSidenav', ($mdMedia, $mdSidenav) ->
  scope: false
  restrict: 'E'
  templateUrl: 'generated/components/sidebar/sidebar.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.currentState = ""
    $scope.showSidebar = true
    InboxService.load()

    $scope.canStartThreads = ->
      _.some Session.user().groups(), (group) -> AbilityService.canStartThread(group)

    availableGroups = ->
      _.filter Session.user().groups(), (group) -> group.type == 'FormalGroup'

    $scope.currentGroup = ->
      return _.head(availableGroups()) if availableGroups().length == 1
      _.find(availableGroups(), (g) -> g.id == (AppConfig.currentGroup or {}).id) || Records.groups.build()

    EventBus.listen $scope, 'toggleSidebar', (event, show) ->
      if !_.isUndefined(show)
        $scope.showSidebar = show
      else
        $scope.showSidebar = !$scope.showSidebar

    EventBus.listen $scope, 'currentComponent', (el, component) ->
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

    $scope.canLockSidebar = -> $mdMedia("gt-sm")

    $scope.sidebarItemSelected = ->
      $mdSidenav('left').close() if !$scope.canLockSidebar()

    $scope.groups = ->
      _.filter Session.user().groups().concat(Session.user().orphanParents()), (group) ->
        group.type == "FormalGroup"

    $scope.currentUser = ->
      Session.user()

    $scope.canStartGroup = -> AbilityService.canStartGroups()
    $scope.canViewPublicGroups = -> AbilityService.canViewPublicGroups()

    $scope.startGroup = ->
      ModalService.open 'GroupModal', group: -> Records.groups.build()

    $scope.startThread = ->
      ModalService.open 'DiscussionStartModal', discussion: -> Records.discussions.build(groupId: $scope.currentGroup().id)
  ]
]
