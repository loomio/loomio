angular.module('loomioApp').controller 'CloseProposalFormController', ($scope, FormService, proposal) ->
  # TODO: add flash message
  $scope.proposal = proposal

  $scope.submit = FormService.submit $scope, $scope.proposal,
    submitFn: $scope.proposal.close
