angular.module('loomioApp').directive 'proposalPositionsPanel', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_positions_panel/proposal_positions_panel.html'
  replace: true
  controller: ($scope, Records, Session, ModalService, VoteForm, AbilityService) ->

    $scope.undecidedPanelOpen = false

    $scope.changeVote = ->
      ModalService.open VoteForm, vote: -> $scope.proposal.lastVoteByUser(Session.current()).clone()

    sortValueForVote = (vote) ->
      positionValues = {yes: 1, abstain: 2, no: 3, block: 4}
      if $scope.voteIsMine(vote)
        0
      else
        positionValues[vote.position]

    $scope.curatedVotes = ->
      _.sortBy $scope.proposal.uniqueVotes(), (vote) ->
        sortValueForVote(vote)

    $scope.voteIsMine = (vote) ->
      vote.authorId == Session.current().id

    $scope.showChangeVoteOption = (vote) ->
      AbilityService.canVoteOn($scope.proposal) and $scope.voteIsMine(vote)

    $scope.showUndecided = ->
      $scope.undecidedPanelOpen = true
