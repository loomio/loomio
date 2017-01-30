angular.module('loomioApp').controller 'NewOutcomeItemController', ($scope, Records) ->
  $scope.outcome = Records.outcomes.find($scope.event.eventable.id)
