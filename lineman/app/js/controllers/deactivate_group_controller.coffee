angular.module('loomioApp').controller 'DeactivateGroupController', ($scope, $modalInstance, group, GroupService, UserAuthService) ->
  $scope.group = group

  $scope.submit = ->
    $scope.isDisabled = true
    GroupService.archive $scope.group, $scope.saveSuccess, $scope.saveError

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel');

  $scope.saveSuccess = () ->
    $scope.isDisabled = false
    $modalInstance.close();

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

