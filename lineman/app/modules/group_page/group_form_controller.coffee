angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, group, FormService, UserAuthService) ->
  $scope.group = group

  onSuccess = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  FormService.applyForm $scope, group, onSuccess

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
