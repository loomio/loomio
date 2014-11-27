angular.module('loomioApp').controller 'ProposalCloseFormController', ($scope, $modalInstance, proposal, ProposalService) ->
  $scope.proposal = proposal

  $scope.submit = ->
    $scope.proposal.closedAt = Date.now
    ProposalService.close $scope.proposal, $scope.saveSuccess, $scope.saveFailure

  $scope.saveSuccess = ->
    $modalInstance.close()

  $scope.saveFailure = (errors) ->
    console.log(errors)

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel')
