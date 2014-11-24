angular.module('loomioApp').controller 'GroupNotificationsDropdownController', ($scope, GroupService, MessageChannelService, MembershipService, UserAuthService) ->
  MembershipService.fetchMyMemberships ->
    $scope.membership = UserAuthService.currentUser.membershipFor($scope.group)

  $scope.followGroup = (following) ->
    $scope.membership.followingByDefault = following
    MembershipService.save $scope.membership, $scope.saveMembershipSuccess, $scope.saveMembershipFailure
 
  $scope.saveMembershipSuccess = ->
    console.log('success!')

  $scope.saveMembershipFailure = ->
    console.log('failure...')
