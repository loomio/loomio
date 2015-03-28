angular.module('loomioApp').controller 'GroupActionsDropdownController', ($modal, UserAuthService, CurrentUser) ->

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
