angular.module('loomioApp').directive 'previousProposalsCard', ->
  scope: {}
  bindToController: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/previous_proposals_card/previous_proposals_card.html'
  replace: true
  controllerAs: 'previousProposalsCard'
  controller: ($scope, Records, ProposalFormService) ->

    $scope.selectedProposalId = 0

    $scope.$on 'collapseProposal', (event) ->
      $scope.selectedProposalId = 0

    @proposals = ->
      @discussion.closedProposals()

    @selectProposal = (proposal) =>
      $scope.selectedProposalId = proposal.id

    return
