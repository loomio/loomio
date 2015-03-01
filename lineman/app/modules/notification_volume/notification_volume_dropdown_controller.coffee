angular.module('loomioApp').controller 'NotificationVolumeDropdownController', ($scope, Records, UserAuthService) ->
  $scope.init = ->
    if $scope.group
      $scope.model = $scope.group.membershipFor(UserAuthService.currentUser)
      $scope.showButton = true
    else if $scope.discussion
      $scope.model = Records.discussionReaders.find($scope.discussion.id)
  $scope.init()