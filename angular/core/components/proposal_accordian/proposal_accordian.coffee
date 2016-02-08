angular.module('loomioApp').directive 'proposalAccordian', ->
  scope: {model: '=', selectedProposalId: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/proposal_accordian/proposal_accordian.html'
  replace: true
  controller: ($scope, CurrentUser) ->

    $scope.$on 'collapseProposal', (event) ->
      $scope.selectedProposalId = null

    $scope.selectProposal = (proposal) =>
      $scope.selectedProposalId = proposal.id
