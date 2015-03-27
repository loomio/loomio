angular.module('loomioApp').controller 'MembersCardController', ($scope, Records, CurrentUser) ->
  Records.memberships.fetchByGroup $scope.group

  $scope.canAddMembers = ->
    $scope.group.membersCanAddMembers or CurrentUser.isAdminOf($scope.group)

  $scope.isAdminOf = ->
    CurrentUser.isAdminOf($scope.group)
