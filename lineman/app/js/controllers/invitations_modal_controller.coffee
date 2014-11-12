angular.module('loomioApp').controller 'InvitationsModalController', ($scope, $modalInstance, group) ->
  $scope.group = group
  $scope.invitations = []

  $scope.submit = ->
    $scope.isDisabled = true
    InvitableService.sendInvitations($scope.invitations, $scope.saveSuccess, $scope.saveError)

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel');

  $scope.saveSuccess = () ->
    $scope.isDisabled = false
    $modalInstance.close();

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

