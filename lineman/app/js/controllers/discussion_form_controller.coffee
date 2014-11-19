angular.module('loomioApp').controller 'DiscussionFormController', ($scope, $modalInstance, DiscussionService, discussion) ->
  $scope.discussion = discussion

  $scope.saveSuccess = ->
    console.log 'saved the discussion'
    $modalInstance.close()

  $scope.saveError = (error) ->
    console.log error

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel')

  $scope.submit = ->
    DiscussionService.save($scope.discussion, $scope.saveSuccess, $scope.saveError)
