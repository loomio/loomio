angular.module('loomioApp').factory 'ProposalOutcomeForm', ->
  templateUrl: 'generated/components/thread_page/proposal_outcome_form/proposal_outcome_form.html'
  controller: ($scope, proposal, FormService, EmojiService) ->
    $scope.proposal = proposal.clone()
    $scope.hasOutcome = proposal.hasOutcome()

    $scope.submit = FormService.submit $scope, $scope.proposal,
      if !$scope.hasOutcome
        submitFn: $scope.proposal.createOutcome
        flashSuccess: 'proposal_outcome_form.messages.created'
      else
        submitFn: $scope.proposal.updateOutcome
        flashSuccess: 'proposal_outcome_form.messages.updated'

      $scope.outcomeSelector = '.proposal-form__outcome-field'
      EmojiService.listen $scope, $scope.proposal, 'outcome', $scope.outcomeSelector
