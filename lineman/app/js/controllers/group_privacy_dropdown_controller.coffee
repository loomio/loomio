angular.module('loomioApp').controller 'GroupPrivacyDropdownController', ($scope, GroupService, MessageChannelService) ->

  $scope.setPrivacy = (privacy) ->
    $scope.group.visibleTo = privacy
    GroupService.save($scope.group, $scope.savePrivacySuccess, $scope.savePrivacyFailure)

  $scope.savePrivacySuccess = ->
    console.log('success!')

  $scope.savePrivacyFailure = ->
    console.log('failure...')