angular.module('loomioApp').controller 'MembershipsPageController', ($scope, group, UserAuthService) ->
  Records.groups.fetchByKey(groupKey)
  Records.memberships.fetchByGroupKey groupKey

  $scope.group = Records.groups.getOrInitialize(key: groupKey)

  $scope.userIsAdmin = ->
    UserAuthService.currentUser.isAdminOf($scope.group)

  $scope.toggleMembershipAdmin = (membership) ->
    if membership.admin
      membership.removeAdmin()
    else
      membership.makeAdmin()

  $scope.destroyMembership = (membership) ->
    membership.destroy()
