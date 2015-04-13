angular.module('loomioApp').controller 'GroupPrivacyDropdownController', ($scope, MessageChannelService, UserAuthService, FlashService, CurrentUser) ->

  $scope.savePrivacy = ->
    return true unless $scope.canEditGroup()
    $scope.group.save().then ->
      FlashService.success('group_page.messages.privacy.' + $scope.group.visibleTo)

  $scope.canEditGroup = ->
    CurrentUser.isAdminOf($scope.group)

  return