angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, GroupService, group, FormService) ->
  $scope.group = group

  FormService.applyForm $scope, GroupService.save, group

  $scope.successCallback = (newGroup) ->
    $location.path "/g/#{newGroup.key}"
