angular.module('loomioApp').controller 'GroupController', ($scope, groupKey, group, Records, MessageChannelService, UserAuthService) ->
  console.log 'resolved promise', group
  console.log Records.groups.find(groupKey)
  $scope.group = group

  console.log 'group', group
  MessageChannelService.subscribeTo("/group-#{group.key}")

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
