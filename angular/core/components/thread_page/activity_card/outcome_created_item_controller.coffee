angular.module('loomioApp').controller 'OutcomeCreatedItemController', ($scope, Records) ->
  $scope.outcome = Records.outcomes.find($scope.event.eventable.id)
