angular.module('loomioApp').directive 'pollCommonDidNotVotesPanel', (Records, RecordLoader, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/did_not_votes_panel/poll_common_did_not_votes_panel.html'
  controller: ($scope) ->

    $scope.canShowUndecided = ->
      $scope.poll.undecidedCount() > 0 and !$scope.showingUndecided

    collection = $scope.poll.isActive() ? 'memberships' : 'poll_did_not_votes'

    didNotVotesLoader = new RecordLoader
      collection: 'poll_did_not_votes'
      params:
        poll_id: $scope.poll.key

    membershipsLoader = new RecordLoader
      collection: 'memberships'
      path: 'undecided'
      params:
        poll_id: $scope.poll.key

    $scope.loader = if $scope.poll.group() and $scope.poll.isActive()
      membershipsLoader
    else
      didNotVotesLoader

    $scope.moreToLoad = ->
      $scope.loader.numLoaded < $scope.poll.undecidedCount()

    $scope.showUndecided = ->
      $scope.showingUndecided = true
      $scope.loader.fetchRecords()
