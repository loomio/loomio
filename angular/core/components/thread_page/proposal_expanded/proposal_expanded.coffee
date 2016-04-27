angular.module('loomioApp').directive 'proposalExpanded', ->
  scope: {proposal: '=', canCollapse: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_expanded/proposal_expanded.html'
  replace: true
  controller: ($scope, Records, User, AbilityService, TranslationService) ->
    Records.votes.fetchByProposal($scope.proposal)

    $scope.collapse = ->
      $scope.$emit('collapseProposal')

    $scope.showActionsDropdown = ->
      AbilityService.canCloseOrExtendProposal($scope.proposal)

    $scope.onlyVoterIsYou = ->
      uniqueVotes = $scope.proposal.uniqueVotes()
      (uniqueVotes.length == 1) and (uniqueVotes[0].authorId == User.current().id)

    $scope.currentUserHasVoted = ->
      $scope.proposal.userHasVoted(User.current())

    $scope.currentUserVote = ->
      $scope.proposal.lastVoteByUser(User.current())

    $scope.showOutcomePanel = ->
      $scope.proposal.hasOutcome() or AbilityService.canCreateOutcomeFor($scope.proposal)

    TranslationService.listenForTranslations($scope)
