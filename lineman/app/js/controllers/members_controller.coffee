angular.module('loomioApp').controller 'MembersController', ($scope, MembershipService, UserAuthService) ->
  MembershipService.fetchByGroup $scope.group.id

  $scope.canAddMembers = ->
    $scope.group.membersCanAddMembers or UserAuthService.currentUser.isAdminOf($scope.group)

  $scope.isAdminOf = ->
    UserAuthService.currentUser.isAdminOf($scope.group)