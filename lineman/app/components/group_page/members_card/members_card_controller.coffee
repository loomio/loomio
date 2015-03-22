angular.module('loomioApp').controller 'MembersCardController', ($scope, Records, UserAuthService) ->
  Records.memberships.fetchByGroup $scope.group.key

  $scope.canAddMembers = ->
    $scope.group.membersCanAddMembers or window.Loomio.currentUser.isAdminOf($scope.group)

  $scope.isAdminOf = ->
    window.Loomio.currentUser.isAdminOf($scope.group)
