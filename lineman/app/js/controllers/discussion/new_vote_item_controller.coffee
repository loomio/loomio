angular.module('loomioApp').controller 'NewVoteItemController', ($scope) ->
  vote = $scope.event.vote()
  $scope.vote = vote
