angular.module('loomioApp').controller 'MotionClosedItemController', ($scope) ->
  $scope.actorName = event.actorName()
  $scope.title = $scope.event.proposal().name
