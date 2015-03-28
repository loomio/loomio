angular.module('loomioApp').directive 'groupActionsDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_actions_dropdown/group_actions_dropdown.html'
  replace: true
  controllerAs: 'groupActions'
  controller: ($scope, $modal, UserAuthService, CurrentUser) ->
    @group = $scope.group

    @canEditGroup = =>
      CurrentUser.isAdminOf(@group)

    @canDeactivateGroup = =>
      CurrentUser.isAdminOf(@group)

    @openLeaveGroupModal = =>
      $modal.open
        templateUrl: 'generated/components/group_page/group_actions_dropdown/leave_group.html'
        controller: 'LeaveGroupController'
        resolve:
          group: => @group

    @openDeactivateGroupModel = =>
      $modal.open
        templateUrl: 'generated/components/group_page/group_actions_dropdown/deactivate_group.html'
        controller: 'DeactivateGroupController'
        resolve:
          group: => @group

    return
