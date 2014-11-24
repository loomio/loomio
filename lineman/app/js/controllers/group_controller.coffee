angular.module('loomioApp').controller 'GroupController', ($scope, $modal, group, GroupService, MessageChannelService) ->
  $scope.group = group

  $scope.openGroupSettingsForm = ->
    $modal.open
      templateUrl: 'generated/templates/group_form.html',
      controller: 'GroupFormController',
      resolve:
        group: ->
          angular.copy($scope.group)

  $scope.setPrivacy = (privacy) ->
    $scope.group.visibleTo = privacy
    GroupService.save($scope.group, $scope.savePrivacySuccess, $scope.savePrivacyFailure)

  $scope.savePrivacySuccess = ->
    console.log('success!')

  $scope.savePrivacyFailure = ->
    console.log('failure...')

  onMessageReceived = ->
    console.log 'on message received called, yay'
    $scope.$digest()

  MessageChannelService.subscribeTo("/group-#{group.id}", onMessageReceived)
