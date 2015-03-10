angular.module('loomioApp').controller 'LeaveGroupController', ($scope, $modalInstance, group, Records, UserAuthService, FormService) ->
  $scope.group = group
  membership = group.membershipFor(window.Loomio.currentUser)

  $scope.onSuccess (membership) -> membership.destroy()

  $scope.successMessage = 'group_page.messages.leave_group_success'

  FormService.applyForm $scope, membership, $modalInstance
