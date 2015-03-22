angular.module('loomioApp').controller 'MembershipsPageController', ($scope, group, Records) ->
  $scope.group = group
  Records.memberships.fetchByGroup group

  $scope.userIsAdmin = ->
    window.Loomio.currentUser.isAdminOf($scope.group)

  $scope.toggleMembershipAdmin = (membership) ->
    if membership.admin
      membership.removeAdmin()
    else
      membership.makeAdmin()

  $scope.destroyMembership = (membership) ->
    membership.destroy()
