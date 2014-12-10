angular.module('loomioApp').controller 'MembersCardController', ($scope, Records, UserAuthService) ->
  Records.memberships.fetchByGroup $scope.group

  $scope.canAddMembers = ->
    $scope.group.membersCanAddMembers or UserAuthService.currentUser.isAdminOf($scope.group)

  $scope.isAdminOf = ->
    UserAuthService.currentUser.isAdminOf($scope.group)
