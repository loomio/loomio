angular.module('loomioApp').controller 'NewMotionItemController', ($scope) ->
  $scope.motion = $scope.event.eventable
