angular.module('loomioApp').controller 'GroupPrivacyDropdownController', ($scope, FlashService, AbilityService) ->

  $scope.savePrivacy = ->
    return true unless $scope.canEditGroup()
    $scope.group.save().then ->
      FlashService.success('group_page.messages.privacy.' + $scope.group.visibleTo)

  $scope.canEditGroup = ->
    AbilityService.canEditGroup($scope.group)

  return
  