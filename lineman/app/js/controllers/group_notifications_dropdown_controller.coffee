angular.module('loomioApp').controller 'GroupNotificationsDropdownController', ($scope, MessageChannelService, UserAuthService, FlashService) ->
  $scope.membership = UserAuthService.currentUser.membershipFor($scope.group)

  $scope.followGroup = (following) ->
    $scope.membership.followingByDefault = following
    $scope.membership.save $scope.saveMembershipSuccess, $scope.saveMembershipFailure
 
  $scope.saveMembershipSuccess = ->
    if $scope.membership.followingByDefault
      message = 'flash.group_page.notifications.follow_group'
    else
      message = 'flash.group_page.notifications.unfollow_group'
    FlashService.success(message)

  $scope.saveMembershipFailure = (errors) ->
    FlashService.error(errors)
