angular.module('loomioApp').controller 'GroupPrivacyDropdownController', ($scope, GroupService, MessageChannelService, UserAuthService) ->

  $scope.setPrivacy = (privacy) ->
    return true unless $scope.canEditGroup()
    $scope.group.visibleTo = privacy
    GroupService.save($scope.group, $scope.savePrivacySuccess, $scope.savePrivacyFailure)

  $scope.savePrivacySuccess = ->
    console.log('success!')

  $scope.savePrivacyFailure = ->
    console.log('failure...')

  $scope.canEditGroup = ->
    UserAuthService.currentUser.isAdminOf($scope.group)