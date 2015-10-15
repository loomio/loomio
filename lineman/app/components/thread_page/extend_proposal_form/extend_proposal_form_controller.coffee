angular.module('loomioApp').controller 'ExtendProposalFormController', ($scope, $modalInstance, proposal, FlashService) ->
  $scope.proposal = proposal.clone()

  $scope.submit = ->
    $scope.proposal.save().then ->
      $modalInstance.close()
      FlashService.success 'extend_proposal_form.success'

  $scope.cancel = ($event) ->
    $scope.$close()
