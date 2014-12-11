angular.module('loomioApp').controller 'FormController', ($scope, record, FlashService) ->

  $scope.save = ->
    if record.isNew()
      record.save().then($scope.onCreateSuccess, $scope.onFailure)
    else
      record.save().then($scope.onUpdateSuccess, $scope.onFailure)

  $scope.destroy = ->
    record.destroy().then($scope.onDestroySuccess, $scope.onFailure)

  $scope.onCreateSuccess  = -> $scope.onSuccess 'created'
  $scope.onUpdateSuccess  = -> $scope.onSuccess 'updated'
  $scope.onDestroySuccess = -> $scope.onSuccess 'destroyed'
  $scope.onFailure        = (errors) -> console.log 'i am an errorconda:', errors

  $scope.onSuccess = (action) ->
    $scope.$close() if $scope.$close?
    FlashService.success record.constructor.singular, action, record.translationOptions()
