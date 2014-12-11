angular.module('loomioApp').controller 'ProposalActionsDropdownController', ($scope, ProposalFormService, UserAuthService) ->

  $scope.canCloseOrExtendProposal = ->
    UserAuthService.currentUser.canCloseOrExtendProposal($scope.proposal)

  $scope.canEditProposal = ->
    UserAuthService.currentUser.canEditProposal($scope.proposal)

  $scope.editProposal = ->
    ProposalFormService.openEditProposalModal($scope.proposal)

  $scope.closeProposal = ->
    ProposalFormService.openCloseProposalModal($scope.proposal)
