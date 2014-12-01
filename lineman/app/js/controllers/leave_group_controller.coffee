angular.module('loomioApp').controller 'LeaveGroupController', ($scope, $modalInstance, group, MembershipService, UserAuthService, FormService) ->
  $scope.group = group
  membership = group.membershipFor(UserAuthService.currentUser)

  $scope.successMessage = 'flash.group_page.leave_group_success'
  FormService.applyForm $scope, MembershipService.destroy, membership, $modalInstance