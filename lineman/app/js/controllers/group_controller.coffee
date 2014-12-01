angular.module('loomioApp').controller 'GroupController', ($scope, group, Records, MessageChannelService, UserAuthService) ->
  console.log 'group', group
  $scope.group = group

  MessageChannelService.subscribeTo("/group-#{group.key}")

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned

  $scope.isMember = ->
    UserAuthService.currentUser.membershipFor($scope.group)?

  $scope.joinGroup = ->
    Records.memberships.create(group_id: $scope.group.id)
