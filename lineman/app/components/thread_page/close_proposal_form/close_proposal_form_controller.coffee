angular.module('loomioApp').controller 'CloseProposalFormController', ($scope, $modalInstance, proposal, FlashService) ->
  $scope.proposal = proposal

  $scope.submit = ->
    $scope.proposal.close().then ->
      $modalInstance.close()
      FlashService.success 'close_proposal_form.messages.success'

  $scope.cancel = ($event) ->
    $modalInstance.dismiss('cancel')
