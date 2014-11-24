angular.module('loomioApp').controller 'GroupFormController', ($scope, GroupService, group) ->
  $scope.group = group

  $scope.saveSuccess = ->
    $modalInstance.close()

  $scope.saveError = (error) ->
    console.log error

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel')

  $scope.submit = ->
    GroupService.save($scope.discussion, $scope.saveSuccess, $scope.saveError)
