angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, GroupService, group) ->
  $scope.group = group

  FormService.applyForm $scope, GroupService, group

  $scope.saveSuccess = ->
    $location.path "/g/#{$scope.group.key}"
