angular.module('loomioApp').controller 'ProposalFormController', ($scope, $modalInstance, proposal, ProposalService, FormService) ->
  $scope.proposal = proposal
  proposalHasVotes = proposal.votes()?
  
  FormService.applyForm $scope, ProposalService.save, proposal, $modalInstance

  $scope.onSetTime = -> $scope.dropdownIsOpen = false

  $scope.isUneditable = -> $scope.isDisabled or proposalHasVotes

