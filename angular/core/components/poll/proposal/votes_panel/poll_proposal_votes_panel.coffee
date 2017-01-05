angular.module('loomioApp').directive 'pollProposalVotesPanel', (Records, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/votes_panel/poll_proposal_votes_panel.html'
  controller: ($scope) ->
    $scope.sortOptions = PollService.fieldFromTemplate('proposal', 'sort_options')
    $scope.votesOrder = $scope.sortOptions[0]

    # per = limit
    # from = offset
    per = 1
    from = 0

    $scope.loadMore = ->
      from += per
      $scope.fetchRecords()

    idSet = new Set();

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
      filteredStances = _.filter $scope.poll.uniqueStances(), (stance) -> idSet.has(stance.id)
      _.sortBy filteredStances, sortFn[$scope.votesOrder]

    $scope.fetchRecords = ->
      Records.stances.fetch
        params:
          poll_id: $scope.poll.key
          order: $scope.votesOrder
          from: from
          per: per
      .then (response) ->
        _.each response.stances, (stance) -> idSet.add(stance.id)

    $scope.fetchRecords()
