angular.module('loomioApp').controller 'DeactivateGroupController', ($scope, $modalInstance, group, UserAuthService, FormService) ->
  $scope.group = group

  onSuccess = ->
    group.archive()
    FlashService.success 'group_page.messages.deactivate_group_success'

  FormService.applyModalForm $scope, group, $modalInstance, onSuccess
