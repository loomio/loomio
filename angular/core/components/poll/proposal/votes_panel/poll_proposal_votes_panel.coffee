angular.module('loomioApp').directive 'pollProposalVotesPanel', (Records, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/votes_panel/poll_proposal_votes_panel.html'
  controller: ($scope) ->
    per = 1 # limit
    from = 0 # offset
    total = 0

    # sorry. ng-if and md-select break. github.com/angular/material/issues/3940
    $scope.fix = {}
    $scope.sortOptions = PollService.fieldFromTemplate($scope.poll.pollType, 'sort_options')
    $scope.fix.votesOrder = $scope.sortOptions[0]

    $scope.hasSomeVotes = ->
      $scope.stances().length > 0

    $scope.moreToLoad = ->
      $scope.stances().length < $scope.poll.stancesCount

    sortFn =
      newest_first: (stance) ->
        -(stance.createdAt)
      oldest_first: (stance) ->
        stance.createdAt
      priority_first: (stance) ->
        stance.pollOption().priority
      priority_last: (stance) ->
        -(stance.pollOption().priority)

    $scope.stances = ->
      $scope.poll.uniqueStances(sortFn[$scope.fix.votesOrder], total)

    $scope.fetchRecords = ->
      Records.stances.fetch
        params:
          poll_id: $scope.poll.key
          order: $scope.fix.votesOrder
          from: from
          per: per
      .then (data) ->
        total += data.stances.length

    $scope.loadMore = ->
      from += per
      $scope.fetchRecords()

    $scope.changeOrder = ->
      from = 0 # offset
      total = 0
      $scope.fetchRecords()

    $scope.fetchRecords()
