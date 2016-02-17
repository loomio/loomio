angular.module('loomioApp').directive 'proposalOutcomePanel', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_outcome_panel/proposal_outcome_panel.html'
  replace: true
  controller: ($scope, AbilityService, ProposalFormService) ->

    $scope.canCreateOutcome = ->
      AbilityService.canCreateOutcomeFor($scope.proposal)

    $scope.openProposalOutcomeForm = ->
      ProposalFormService.openSetOutcomeModal($scope.proposal)

    $scope.canUpdateOutcome = ->
     AbilityService.canUpdateOutcomeFor($scope.proposal)

    return
