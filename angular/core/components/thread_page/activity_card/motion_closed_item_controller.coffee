angular.module('loomioApp').controller 'MotionClosedItemController', ($scope) ->
  $scope.proposal = $scope.event.proposal()
