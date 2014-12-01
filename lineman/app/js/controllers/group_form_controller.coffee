angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, group, FormService, UserAuthService) ->
  group = Records.groups.findOrFetch(groupKey)
  $scope.group = group

  FormService.applyForm $scope, group

  $scope.onSuccess = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
