angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controllerAs: 'groupActions'
  controller: ($scope, $modal, AbilityService) ->

    @canEditGroup = =>
      AbilityService.canEditGroup($scope.group)

    @canDeactivateGroup = =>
      AbilityService.canDeactivateGroup($scope.group)

    @openLeaveGroupModal = =>
      $modal.open
        templateUrl: 'generated/components/group_page/group_actions_dropdown/leave_group.html'
        controller: 'LeaveGroupController'
        resolve:
          group: => $scope.group

    @openDeactivateGroupModel = =>
      $modal.open
        templateUrl: 'generated/components/group_page/group_actions_dropdown/deactivate_group.html'
        controller: 'DeactivateGroupController'
        resolve:
          group: => $scope.group

    return
