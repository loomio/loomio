angular.module('loomioApp').controller 'ProposalOutcomeFormController', ($scope, proposal, FormService, Records) ->
  $scope.proposal = proposal.clone()
  $scope.hasOutcome = proposal.hasOutcome()

  $scope.submit = FormService.submit $scope, $scope.proposal,
    submitFn: Records.proposals.createOutcome
    flashSuccess: 'proposal_outcome_form.messages.created'
