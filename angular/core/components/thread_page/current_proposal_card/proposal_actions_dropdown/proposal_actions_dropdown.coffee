angular.module('loomioApp').directive 'proposalActionsDropdown', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/current_proposal_card/proposal_actions_dropdown/proposal_actions_dropdown.html'
  replace: true
  controller: ($scope, ModalService, ProposalForm, AbilityService, CloseProposalForm, ExtendProposalForm) ->
    $scope.canCloseOrExtendProposal = ->
      AbilityService.canCloseOrExtendProposal($scope.proposal)

    $scope.canEditProposal = ->
      AbilityService.canEditProposal($scope.proposal)

    $scope.editProposal = ->
      ModalService.open ProposalForm, proposal: -> $scope.proposal.clone()

    $scope.closeProposal = ->
      ModalService.open CloseProposalForm, proposal: -> $scope.proposal

    $scope.extendProposal = ->
      ModalService.open ExtendProposalForm, proposal: -> $scope.proposal
    return
