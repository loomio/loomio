angular.module('loomioApp').controller 'ProposalCardDropdownController', ($scope, $modal) ->

  $scope.editProposal = ->
    $modal.open
      templateUrl: 'generated/modules/discussion_page/proposals_card/proposal_form.html',
      controller: 'ProposalFormController',
      resolve:
        proposal: -> $scope.proposal

  $scope.closeProposal = ->
    $modal.open
      templateUrl: 'generated/modules/discussion_page/proposals_card/close_proposal_form.html',
      controller: 'ProposalCloseFormController',
      resolve:
        proposal: -> $scope.proposal
