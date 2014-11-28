angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, GroupService, group, FormService, UserAuthService) ->
  $scope.group = group

  FormService.applyForm $scope, GroupService.save, group

  $scope.successCallback = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
