angular.module('loomioApp').controller 'GroupFormController', ($scope, GroupService, group) ->
  $scope.group = group

  $scope.saveSuccess = ->
    console.log 'success!'

  $scope.saveError = (error) ->
    console.log error

  $scope.submit = ->
    GroupService.save($scope.group, $scope.saveSuccess, $scope.saveError)
