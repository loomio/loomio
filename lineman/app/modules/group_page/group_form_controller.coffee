angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, group, FormService) ->
  $scope.group = group

  onSuccess = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  FormService.applyForm $scope, group, onSuccess
