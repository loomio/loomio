angular.module('loomioApp').controller 'NewProposalItemController', ($scope) ->
  $scope.proposal = $scope.event.proposal()
