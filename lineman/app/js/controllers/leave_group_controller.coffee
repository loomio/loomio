angular.module('loomioApp').controller 'LeaveGroupController', ($scope, $modalInstance, group, MembershipService, UserAuthService) ->
  $scope.group = group
  $scope.membership = group.membershipFor(UserAuthService.currentUser)

  $scope.submit = ->
    $scope.isDisabled = true
    MembershipService.destroy($scope.membership, $scope.saveSuccess, $scope.saveError)

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel');

  $scope.saveSuccess = () ->
    $scope.isDisabled = false
    $modalInstance.close();

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

