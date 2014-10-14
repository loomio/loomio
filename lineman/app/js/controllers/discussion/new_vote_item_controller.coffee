angular.module('loomioApp').controller 'NewVoteItemController', ($scope) ->
  vote = $scope.event.vote()
  $scope.vote = vote
  $scope.translationData =
    name: vote.author_name()
