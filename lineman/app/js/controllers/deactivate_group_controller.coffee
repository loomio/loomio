angular.module('loomioApp').controller 'DeactivateGroupController', ($scope, $modalInstance, group, UserAuthService, FormService) ->
  $scope.group = group

  $scope.successMessage = ->
    'flash.group_page.deactivate_group_success'

  FormService.applyForm $scope, group.archive, group, $modalInstance
