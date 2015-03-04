angular.module('loomioApp').controller 'SubgroupsCardController', ($scope, Records, UserAuthService) ->
  Records.groups.fetchByParent $scope.group

  $scope.canCreateSubgroups = ->
    window.Loomio.currentUser.isMemberOf($scope.group) and
      ($scope.group.membersCanCreateSubgroups or window.Loomio.currentUser.isAdminOf($scope.group))
