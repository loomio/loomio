angular.module('loomioApp').controller 'GroupController', ($scope, group, MessageChannelService, UserAuthService) ->
  $scope.group = group

  onMessageReceived = ->
    console.log 'on message received called, yay'
    $scope.$digest()

  MessageChannelService.subscribeTo("/group-#{group.id}", onMessageReceived)

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
