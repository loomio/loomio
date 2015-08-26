angular.module('loomioApp').controller 'MotionOutcomeCreatedItemController', ($scope) ->
  $scope.proposal = $scope.event.proposal()
