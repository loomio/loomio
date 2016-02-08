angular.module('loomioApp').controller 'ExtendProposalFormController', ($scope, proposal, FlashService) ->
  $scope.proposal = proposal.clone()

  $scope.submit = ->
    $scope.proposal.save().then ->
      $scope.$close()
      FlashService.success 'extend_proposal_form.success'

  $scope.cancel = ($event) ->
    $scope.$close()
