angular.module('loomioApp').directive 'proposalActionsDropdown', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/current_proposal_card/proposal_actions_dropdown/proposal_actions_dropdown.html'
  replace: true
  controller: ($scope, ModalService, ProposalForm, ProposalFormService, AbilityService) ->
    $scope.canCloseOrExtendProposal = ->
      AbilityService.canCloseOrExtendProposal($scope.proposal)

    $scope.canEditProposal = ->
      AbilityService.canEditProposal($scope.proposal)

    $scope.editProposal = ->
      ModalService.open ProposalForm, proposal: -> $scope.proposal.clone()

    $scope.closeProposal = ->
      ProposalFormService.openCloseProposalModal($scope.proposal)

    $scope.extendProposal = ->
      ProposalFormService.openExtendProposalModal($scope.proposal)
    return
