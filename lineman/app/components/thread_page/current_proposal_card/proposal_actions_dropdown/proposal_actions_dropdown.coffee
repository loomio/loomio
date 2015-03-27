angular.module('loomioApp').directive 'proposalActionsDropdown', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/current_proposal_card/proposal_actions_dropdown/proposal_actions_dropdown.html'
  replace: true
  controller: ($scope, ProposalFormService, CurrentUser) ->
    $scope.canCloseOrExtendProposal = ->
      CurrentUser.canCloseOrExtendProposal($scope.proposal)

    $scope.canEditProposal = ->
      CurrentUser.canEditProposal($scope.proposal)

    $scope.editProposal = ->
      ProposalFormService.openEditProposalModal($scope.proposal)

    $scope.closeProposal = ->
      ProposalFormService.openCloseProposalModal($scope.proposal)

    $scope.extendProposal = ->
      ProposalFormService.openExtendProposalModal($scope.proposal)
    return
