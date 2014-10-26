angular.module('loomioApp').controller 'VoteFormController', ($scope, $translate, $modalInstance, VoteService, vote) ->
  $scope.vote = vote

  $scope.submit = ->
    $scope.isDisabled = true
    VoteService.create($scope.vote, saveSuccess, saveError)

  $scope.cancel = ($event) ->
    $event.preventDefault();
    $modalInstance.dismiss('cancel');

  saveSuccess = () ->
    $scope.isDisabled = false
    $modalInstance.close();

  saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages


  # something
