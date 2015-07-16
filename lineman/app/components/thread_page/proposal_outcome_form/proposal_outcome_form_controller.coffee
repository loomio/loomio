angular.module('loomioApp').controller 'ProposalOutcomeFormController', ($scope, $modalInstance, proposal, FlashService, Records) ->
  $scope.proposal = proposal.clone()
  $scope.hasOutcome = proposal.hasOutcome()

  $scope.submit = ->
    Records.proposals.createOutcome($scope.proposal).then ->
      $modalInstance.close()
      FlashService.success 'proposal_outcome_form.messages.created'

  $scope.cancel = ->
    $modalInstance.dismiss()
