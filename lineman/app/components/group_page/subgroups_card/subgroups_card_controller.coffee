angular.module('loomioApp').controller 'SubgroupsCardController', ($scope, Records, CurrentUser) ->
  Records.groups.fetchByParent $scope.group

  $scope.canCreateSubgroups = ->
    CurrentUser.isMemberOf($scope.group) and
      ($scope.group.membersCanCreateSubgroups or CurrentUser.isAdminOf($scope.group))

  $scope.showSubgroupsPlaceholder = ->
    CurrentUser.isAdminOf($scope.group) and $scope.group.subgroups().length == 0
