angular.module('loomioApp').controller 'NewMotionController', ($scope) ->
  $scope.proposal = $scope.event.proposal()
