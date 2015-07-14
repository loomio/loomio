angular.module('loomioApp').controller 'ProposalOutcomeFormController', ($scope, proposal, FormService, Records) ->
  $scope.proposal = proposal.clone()
  $scope.hasOutcome = proposal.hasOutcome()

  # TODO: set flash message successfully
  $scope.submit = FormService.submit $scope, $scope.proposal,
    submitFn: Records.proposals.createOutcome
    flashSuccess: 'proposal_outcome_form.success'
