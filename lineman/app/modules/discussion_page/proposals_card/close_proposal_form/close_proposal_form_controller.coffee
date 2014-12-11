angular.module('loomioApp').controller 'CloseProposalFormController', ($scope, $modalInstance, proposal) ->
  $scope.proposal = proposal

  $scope.submit = ->
    $scope.proposal.close().then ->
      $modalInstance.close()

  $scope.cancel = ($event) ->
    $modalInstance.dismiss('cancel')
