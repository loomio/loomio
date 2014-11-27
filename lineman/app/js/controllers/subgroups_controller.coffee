angular.module('loomioApp').controller 'SubgroupsController', ($scope, GroupService, UserAuthService) ->
  GroupService.fetchByParent $scope.group

  $scope.canCreateSubgroups = ->
    UserAuthService.currentUser.isMemberOf($scope.group) and
      ($scope.group.membersCanCreateSubgroups or UserAuthService.currentUser.isAdminOf($scope.group))
