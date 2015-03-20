angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, group, FormService) ->
  $scope.group = group

  $scope.onSuccess = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  FormService.applyForm $scope, group
