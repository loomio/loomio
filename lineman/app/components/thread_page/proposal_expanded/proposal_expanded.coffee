angular.module('loomioApp').directive 'proposalExpanded', ->
  scope: {proposal: '=', canCollapse: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_expanded/proposal_expanded.html'
  replace: true
  controller: ($scope, $modal, Records, CurrentUser) ->
    Records.votes.fetchByProposal($scope.proposal)
    currentUser = CurrentUser

    $scope.collapse = ->
      console.log 'emmitting'
      $scope.$emit('collapseProposal')

    $scope.showActionsDropdown = ->
      currentUser.canCloseOrExtendProposal($scope.proposal)

    $scope.onlyVoterIsYou = ->
      return false unless $scope.proposal
      uniqueVotes = $scope.proposal.uniqueVotes()
      (uniqueVotes.length == 1) and (uniqueVotes[0].authorId == currentUser.id)

    $scope.noVotesYet = ->
      return true unless $scope.proposal
      $scope.proposal.votes().length == 0

    $scope.currentUserHasVoted = ->
      return false unless $scope.proposal
      $scope.proposal.userHasVoted(currentUser)

    $scope.currentUserVote = ->
      return false unless $scope.proposal
      $scope.proposal.lastVoteByUser(currentUser)

    $scope.showVoteToggle = ->
      $scope.curatedVotes().length > 0 and !$scope.showVotes

    $scope.applyVoteToggle = ->
      $scope.showVotes = !$scope.showVotes

    $scope.showOutcomePanel = ->
      currentUser.canCreateOutcomeFor($scope.proposal) or
      $scope.proposal.hasOutcome()
