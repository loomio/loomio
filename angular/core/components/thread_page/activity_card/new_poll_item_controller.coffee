angular.module('loomioApp').controller 'NewPollItemController', ($scope, Records) ->
  $scope.poll = Records.polls.find($scope.event.eventable.id)
