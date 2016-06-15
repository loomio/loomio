angular.module('loomioApp').controller 'MotionOutcomeUpdatedItemController', ($scope, Records) ->
  $scope.proposal = Records.proposals.find($scope.event.eventable.id)
