angular.module('loomioApp').directive 'pollCommonDidNotVotesPanel', ($location, Records, RecordLoader, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/did_not_votes_panel/poll_common_did_not_votes_panel.html'
  controller: ($scope) ->

    $scope.canShowUndecided = ->
      $scope.poll.undecidedCount() > 0 and !$scope.showingUndecided

    collection = $scope.poll.isActive() ? 'memberships' : 'poll_did_not_votes'

    params =
      poll_id: $scope.poll.key
      participation_token: $location.search().participation_token

    didNotVotesLoader = new RecordLoader
      collection: 'poll_did_not_votes'
      params:     params

    membershipsLoader = new RecordLoader
      collection: 'memberships'
      path:       'undecided'
      params:     params

    # todo: must count this properly
    visitorsLoader = new RecordLoader
      collection: 'visitors'
      params:     params
      numLoaded:  1 # <- (the author)

    $scope.loader = if $scope.poll.group() and $scope.poll.isActive()
      membershipsLoader
    else if $scope.poll.group()
      didNotVotesLoader
    else
      visitorsLoader

    $scope.moreToLoad = ->
      $scope.loader.numLoaded < $scope.poll.undecidedCount()

    $scope.showUndecided = ->
      $scope.showingUndecided = true
      $scope.loader.fetchRecords()
