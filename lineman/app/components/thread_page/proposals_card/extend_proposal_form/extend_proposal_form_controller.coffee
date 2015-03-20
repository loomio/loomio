angular.module('loomioApp').controller 'ExtendProposalFormController', ($scope, $modalInstance, proposal, FlashService) ->
  $scope.proposal = proposal

  $scope.submit = ->
    $scope.proposal.save().then ->
      $modalInstance.close()
      FlashService.success 'extend_proposal_form.success'

  $scope.cancel = ($event) ->
    $modalInstance.dismiss('cancel')
