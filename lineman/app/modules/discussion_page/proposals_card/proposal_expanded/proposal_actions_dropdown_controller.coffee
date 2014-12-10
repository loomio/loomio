angular.module('loomioApp').controller 'ProposalActionsDropdownController', ($scope, ProposalFormService) ->
  $scope.editProposal = ->
    ProposalFormService.openEditProposalModal($scope.proposal)

  $scope.closeProposal = ->
    ProposalFormService.openCloseProposalModal($scope.proposal)
