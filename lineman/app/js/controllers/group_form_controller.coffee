angular.module('loomioApp').controller 'GroupFormController', ($scope, $location, GroupService, group) ->
  $scope.group = group

  $scope.saveSuccess = ->
    $location.path "/groups/#{$scope.group.key}"
    console.log 'success!'

  $scope.saveError = (error) ->
    console.log error

  $scope.submit = ->
    GroupService.save($scope.group, $scope.saveSuccess, $scope.saveError)
