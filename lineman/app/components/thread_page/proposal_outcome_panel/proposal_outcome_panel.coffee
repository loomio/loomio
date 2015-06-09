angular.module('loomioApp').directive 'proposalOutcomePanel', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_outcome_panel/proposal_outcome_panel.html'
  replace: true
  controller: ($scope, CurrentUser, ProposalFormService) ->

    $scope.canCreateOutcome = ->
      CurrentUser.canCreateOutcomeFor($scope.proposal)

    $scope.currentUser = ->
      CurrentUser

    $scope.openProposalOutcomeForm = ->
      ProposalFormService.openSetOutcomeModal($scope.proposal)

    $scope.canUpdateOutcome = ->
     CurrentUser.canUpdateOutcomeFor($scope.proposal)

    return
