angular.module('loomioApp').controller 'MembersController', ($scope, Records, UserAuthService) ->
  Records.memberships.fetchByGroupKey $scope.group.key

  $scope.canAddMembers = ->
    $scope.group.membersCanAddMembers or UserAuthService.currentUser.isAdminOf($scope.group)
