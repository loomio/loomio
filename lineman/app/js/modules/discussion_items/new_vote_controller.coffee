angular.module('loomioApp').controller 'NewVoteController', ($scope) ->
  $scope.vote = $scope.event.vote()
