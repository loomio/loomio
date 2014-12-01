angular.module('loomioApp').controller 'GroupNotificationsDropdownController', ($scope, MessageChannelService, UserAuthService, FlashService) ->
  $scope.membership = UserAuthService.currentUser.membershipFor($scope.group)

  onFailure = (errors) ->
    FlashService.error(errors)

  onSuccess = ->
    if $scope.membership.followingByDefault
      message = 'group_page.messages.notifications.follow_group'
    else
      message = 'group_page.messages.notifications.unfollow_group'
    FlashService.success(message)

  $scope.followGroup = (following) ->
    $scope.membership.followingByDefault = following
    $scope.membership.save().then onSuccess, onFailure
