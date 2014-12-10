angular.module('loomioApp').controller 'ProposalActionsDropdownController', ($scope, $modal) ->
  $scope.editProposal = ->
    ProposalFormService.editProposal($scope.proposal)

  $scope.closeProposal = ->
    ProposalFormService.showCloseProposalModal($scope.proposal)
