angular.module('loomioApp').controller 'GroupActionsDropdownController', ($scope, $modal, UserAuthService) ->

  $scope.canEditGroup = ->
    window.Loomio.currentUser.isAdminOf($scope.group)

  $scope.canDeactivateGroup = ->
    window.Loomio.currentUser.isAdminOf($scope.group)

  $scope.openLeaveGroupModal = ->
    $modal.open
      templateUrl: 'generated/components/group_page/group_actions_dropdown/leave_group.html'
      controller: 'LeaveGroupController'
      resolve:
        group: -> $scope.group

  $scope.openDeactivateGroupModel = ->
    $modal.open
      templateUrl: 'generated/components/group_page/group_actions_dropdown/deactivate_group.html'
      controller: 'DeactivateGroupController'
      resolve:
        group: -> $scope.group
