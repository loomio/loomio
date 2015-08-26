angular.module('loomioApp').controller 'ProposalOutcomeFormController', ($scope, proposal, FormService) ->
  $scope.proposal = proposal.clone()
  $scope.hasOutcome = proposal.hasOutcome()

  $scope.submit = FormService.submit $scope, $scope.proposal,
    if !$scope.hasOutcome
      submitFn: $scope.proposal.createOutcome
      flashSuccess: 'proposal_outcome_form.messages.created'
    else
      submitFn: $scope.proposal.updateOutcome
      flashSuccess: 'proposal_outcome_form.messages.updated'
