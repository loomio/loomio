angular.module('loomioApp').controller 'DeactivateGroupController', ($scope, $modalInstance, group, GroupService, UserAuthService, FormService) ->
  $scope.group = group

  $scope.successMessage = ->
    'flash.group_page.deactivate_group_success'

  FormService.applyForm $scope, GroupService.archive, group, $modalInstance
