angular.module('loomioApp').controller 'GroupPageController', ($scope, group, MessageChannelService) ->
  $scope.group = group

  onMessageReceived = ->
    console.log 'on message received called, yay'
    $scope.$digest()

  MessageChannelService.subscribeTo("/group-#{group.id}", onMessageReceived)
