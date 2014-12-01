angular.module('loomioApp').controller 'GroupOptionsDropdownController', ($scope, $modal, UserAuthService) ->

  $scope.canEditGroup = ->
    UserAuthService.currentUser.isAdminOf($scope.group)

  $scope.canDeactivateGroup = ->
    UserAuthService.currentUser.isAdminOf($scope.group)

  $scope.openLeaveGroupModal = ->
    $modal.open
      templateUrl: 'generated/templates/leave_group.html'
      controller: 'LeaveGroupController'
      resolve:
        group: -> $scope.group

  $scope.openDeactivateGroupModel = ->
    $modal.open
      templateUrl: 'generated/templates/deactivate_group.html'
      controller: 'DeactivateGroupController'
      resolve:
        group: -> $scope.group
