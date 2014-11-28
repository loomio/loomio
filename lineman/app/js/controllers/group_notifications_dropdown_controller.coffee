angular.module('loomioApp').controller 'GroupNotificationsDropdownController', ($scope, GroupService, MessageChannelService, MembershipService, UserAuthService, FlashService) ->
  $scope.membership = UserAuthService.currentUser.membershipFor($scope.group)

  $scope.followGroup = (following) ->
    $scope.membership.followingByDefault = following
    MembershipService.save $scope.membership, $scope.saveMembershipSuccess, $scope.saveMembershipFailure
 
  $scope.saveMembershipSuccess = ->
    if $scope.membership.followingByDefault
      message = 'flash.group_page.notifications.follow_group'
    else
      message = 'flash.group_page.notifications.unfollow_group'
    FlashService.success(message)

  $scope.saveMembershipFailure = (errors) ->
    FlashService.error(errors)
