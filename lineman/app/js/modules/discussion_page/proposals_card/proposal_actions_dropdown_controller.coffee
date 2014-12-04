angular.module('loomioApp').controller 'ProposalCardDropdownController', ($scope, $modal) ->

  $scope.editProposal = ->
    $modal.open
      templateUrl: 'generated/templates/proposal_form.html',
      controller: 'ProposalFormController',
      resolve:
        proposal: -> $scope.proposal

  $scope.closeProposal = ->
    $modal.open
      templateUrl: 'generated/templates/proposal_close_form.html',
      controller: 'ProposalCloseFormController',
      resolve:
        proposal: -> $scope.proposal
