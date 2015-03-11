angular.module('loomioApp').controller 'ProposalActionsDropdownController', ($scope, ProposalFormService, UserAuthService) ->

  $scope.canCloseOrExtendProposal = ->
    window.Loomio.currentUser.canCloseOrExtendProposal($scope.proposal)

  $scope.canEditProposal = ->
    window.Loomio.currentUser.canEditProposal($scope.proposal)

  $scope.editProposal = ->
    ProposalFormService.openEditProposalModal($scope.proposal)

  $scope.closeProposal = ->
    ProposalFormService.openCloseProposalModal($scope.proposal)

  $scope.extendProposal = ->
    ProposalFormService.openExtendProposalModal($scope.proposal)
