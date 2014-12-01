angular.module('loomioApp').controller 'DeactivateGroupController', ($scope, $modalInstance, group, UserAuthService, FormService) ->
  $scope.group = group

  $scope.onSuccess ->
    group.archive()

  $scope.successMessage = 'group_page.messages.deactivate_group_success'

  FormService.applyForm $scope, group, $modalInstance
