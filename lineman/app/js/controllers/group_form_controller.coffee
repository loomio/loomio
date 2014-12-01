angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, group, FormService, UserAuthService) ->
  Records.groups.fetchByKey(groupKey)
  group = Records.groups.getOrInitialize(key: groupKey)
  $scope.group = group

  FormService.applyForm $scope, group

  $scope.successCallback = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
