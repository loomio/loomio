angular.module('loomioApp').controller 'GroupOptionsDropdownController', ($scope, $modal, GroupService, UserAuthService) ->

  $scope.canEditGroup = ->
    UserAuthService.currentUser.isAdminOf($scope.group)

  $scope.canDeactivateGroup = ->
    UserAuthService.currentUser.isAdminOf($scope.group)

  $scope.openLeaveGroupModal = ->
    $modal.open
      templateUrl: 'generated/templates/leave_group.html'
      controller: 'LeaveGroupController'
      resolve:
        group: ->
          angular.copy($scope.group)

  $scope.openDeactivateGroupModel = ->
    $modal.open
      templateUrl: 'generated/templates/deactivate_group.html'
      controller: 'DeactivateGroupController'
      resolve:
        group: ->
          angular.copy($scope.group)