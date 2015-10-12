angular.module('loomioApp').directive 'previousProposalsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/previous_proposals_card/previous_proposals_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, Records, ProposalFormService) ->

    Records.votes.fetchMyVotes($scope.discussion.closedProposals())
    Records.proposals.fetchByDiscussion($scope.discussion).then ->
      if proposal = Records.proposals.find($location.search().proposal)
        $scope.selectProposal(proposal)
      $rootScope.$broadcast 'threadPageProposalsLoaded'

    $scope.anyProposals = ->
      $scope.discussion.closedProposals().length > 0

    return
