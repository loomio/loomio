angular.module('loomioApp').controller 'GroupPrivacyDropdownController', ($scope, MessageChannelService, UserAuthService, FlashService, CurrentUser) ->
  onSuccess = ->
    FlashService.success('group_page.messages.privacy.' + $scope.group.visibleTo)

  onFailure = (errors) ->
    FlashService.error(errors)

  $scope.setPrivacy = (privacy) ->
    return true unless $scope.canEditGroup()
    $scope.group.visibleTo = privacy
    $scope.group.save().then onSuccess, onFailure


  $scope.canEditGroup = ->
    CurrentUser.isAdminOf($scope.group)
