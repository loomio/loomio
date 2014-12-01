angular.module('loomioApp').controller 'ProposalCloseFormController', ($scope, $modalInstance, proposal, ProposalService) ->
  $scope.proposal = proposal

  $scope.submit = ->
    scope.proposal.close().then ->
      $modalInstance.close()

  $scope.cancel = ($event) ->
    $modalInstance.dismiss('cancel')
