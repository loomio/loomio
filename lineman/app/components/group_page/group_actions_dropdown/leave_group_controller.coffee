angular.module('loomioApp').controller 'LeaveGroupController', ($scope, $location, $rootScope, $modalInstance, group, FlashService, CurrentUser) ->
  $scope.group = group

  $scope.cancel = ->
    $modalInstance.dismiss 'cancel'

  $scope.submit = ->
    $scope.group.membershipFor(CurrentUser).destroy().then ->
      FlashService.success 'group_page.messages.leave_group_success'
      $modalInstance.dismiss 'success'
      $location.path "/dashboard"
    , ->
      $rootScope.$broadcast 'pageError', 'cantDestroyMembership', group.membershipFor(CurrentUser)
      $modalInstance.dismiss 'failure'