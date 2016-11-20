angular.module('loomioApp').controller 'MotionClosedItemController', ($scope, Records) ->
  $scope.proposal = Records.proposals.find($scope.event.eventable.id)
