angular.module('loomioApp').controller 'MembersCardController', ($scope, Records, UserAuthService) ->
  Records.memberships.fetchByGroup $scope.group

  $scope.canAddMembers = ->
    $scope.group.membersCanAddMembers or window.Loomio.currentUser.isAdminOf($scope.group)

  $scope.isAdminOf = ->
    window.Loomio.currentUser.isAdminOf($scope.group)
