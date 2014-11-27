angular.module('loomioApp').controller 'MembershipsPageController', ($scope, group, MembershipService, UserAuthService) ->
  $scope.group = group
  MembershipService.fetchByGroup group.id

  $scope.userIsAdmin = ->
    UserAuthService.currentUser.isAdminOf(group)

  $scope.toggleMembershipAdmin = (membership) ->
    if membership.admin
      MembershipService.removeAdmin(membership)
    else
      MembershipService.makeAdmin(membership)

  $scope.destroyMembership = (membership) ->
    MembershipService.destroy(membership)
