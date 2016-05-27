angular.module('loomioApp').controller 'MotionOutcomeCreatedItemController', ($scope, Records) ->
  $scope.proposal = Records.proposals.find($scope.event.eventable.id)
