angular.module('loomioApp').controller 'GroupController', ($scope, $modal, group, MessageChannelService) ->
  $scope.group = group

  $scope.openGroupSettingsForm = ->
    $modal.open
      templateUrl: 'generated/templates/group_form.html',
      controller: 'GroupFormController',
      resolve:
        group: ->
          angular.copy($scope.group)

  onMessageReceived = ->
    console.log 'on message received called, yay'
    $scope.$digest()

  MessageChannelService.subscribeTo("/group-#{group.id}", onMessageReceived)
