angular.module('loomioApp').directive 'pollCommonDidNotVotesPanel', (Records, RecordLoader, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/did_not_votes_panel/poll_common_did_not_votes_panel.html'
  controller: ($scope) ->

    $scope.canShowUndecided = ->
      $scope.poll.undecidedCount() > 0 and !$scope.showingUndecided

    $scope.loader = new RecordLoader
      collection: 'poll_did_not_votes'
      per: 1
      params:
        poll_id: $scope.poll.key

    $scope.moreToLoad = ->
      $scope.poll.undecidedCount() > $scope.loader.numLoaded

    $scope.showUndecided = ->
      $scope.showingUndecided = true
      $scope.loader.fetchRecords()
