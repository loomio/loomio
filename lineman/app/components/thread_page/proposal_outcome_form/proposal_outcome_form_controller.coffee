angular.module('loomioApp').controller 'ProposalOutcomeFormController', ($scope, proposal, FormService, Records) ->
  $scope.proposal = proposal.clone()
  $scope.hasOutcome = proposal.hasOutcome()

  $scope.submit = FormService.submit $scope, $scope.proposal,
    if !$scope.hasOutcome
      submitFn: Records.proposals.createOutcome
      flashSuccess: 'proposal_outcome_form.messages.created'
    else
      submitFn: Records.proposals.updateOutcome
      flashSuccess: 'proposal_outcome_form.messages.updated'
