angular.module('loomioApp').controller 'ProposalFormController', ($scope, $modalInstance, proposal, FormService) ->
  $scope.proposal = proposal
  proposalHasVotes = proposal.votes()?

  FormService.applyForm $scope, proposal, $modalInstance

  $scope.onSetTime = -> $scope.dropdownIsOpen = false

  $scope.isUneditable = -> $scope.isDisabled or proposalHasVotes

