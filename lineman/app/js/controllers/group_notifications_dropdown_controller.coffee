angular.module('loomioApp').controller 'GroupNotificationsDropdownController', ($scope, GroupService, MessageChannelService) ->

  $scope.setNotificationLevel = (level) ->
    #$scope.group.visibleTo = privacy
    #GroupService.save($scope.group, $scope.saveNotificationLevelSuccess, $scope.saveNotificationLevelFailure)

  $scope.saveNotificationLevelSuccess = ->
    console.log('success!')

  $scope.saveNotificationLevelFailure = ->
    console.log('failure...')