angular.module('loomioApp').controller 'ProposalActionsDropdownController', ($scope, $modal) ->

  $scope.editProposal = ->
    $modal.open
      templateUrl: 'generated/modules/discussion_page/proposals_card/proposal_form/proposal_form.html',
      controller: 'ProposalFormController',
      resolve:
        proposal: -> $scope.proposal

  $scope.closeProposal = ->
    $modal.open
      templateUrl: 'generated/modules/discussion_page/proposals_card/close_proposal_form/close_proposal_form.html',
      controller: 'CloseProposalFormController',
      resolve:
        proposal: -> $scope.proposal
