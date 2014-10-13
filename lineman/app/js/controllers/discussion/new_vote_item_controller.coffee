angular.module('loomioApp').controller 'NewVoteItemController', ($scope) ->
  $scope.vote = $scope.event.vote()
  
