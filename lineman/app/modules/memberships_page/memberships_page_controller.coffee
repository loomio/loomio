angular.module('loomioApp').controller 'MembershipsPageController', ($scope, group, UserAuthService) ->
  $scope.group = group
  Records.memberships.fetchByGroup group

  $scope.userIsAdmin = ->
    UserAuthService.currentUser.isAdminOf($scope.group)

  $scope.toggleMembershipAdmin = (membership) ->
    if membership.admin
      membership.removeAdmin()
    else
      membership.makeAdmin()

  $scope.destroyMembership = (membership) ->
    membership.destroy()
