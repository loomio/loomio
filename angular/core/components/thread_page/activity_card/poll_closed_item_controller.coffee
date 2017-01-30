angular.module('loomioApp').controller 'PollClosedItemController', ($scope, Records) ->
  $scope.poll = Records.polls.find($scope.event.eventable.id)
