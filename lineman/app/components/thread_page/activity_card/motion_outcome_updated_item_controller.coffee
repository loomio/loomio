angular.module('loomioApp').controller 'MotionOutcomeUpdatedItemController', ($scope) ->
  $scope.proposal = $scope.event.proposal()
