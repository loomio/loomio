angular.module('loomioApp').controller 'GroupPrivacyDropdownController', ($scope, GroupService, MessageChannelService, UserAuthService, FlashService) ->

  $scope.setPrivacy = (privacy) ->
    return true unless $scope.canEditGroup()
    $scope.group.visibleTo = privacy
    GroupService.save($scope.group, $scope.savePrivacySuccess, $scope.savePrivacyFailure)

  $scope.savePrivacySuccess = ->
    FlashService.success('flash.group_page.privacy.' + $scope.group.visibleTo)

  $scope.savePrivacyFailure = (errors) ->
    FlashService.error(errors)

  $scope.canEditGroup = ->
    UserAuthService.currentUser.isAdminOf($scope.group)