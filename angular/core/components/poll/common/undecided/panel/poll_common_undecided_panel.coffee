angular.module('loomioApp').directive 'pollCommonUndecidedPanel', ($location, Records, RecordLoader, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/undecided/panel/poll_common_undecided_panel.html'
  controller: ($scope) ->

    $scope.canShowUndecided = ->
      $scope.poll.undecidedCount() > 0 and !$scope.showingUndecided

    params =
      poll_id: $scope.poll.key
      participation_token: $location.search().participation_token

    $scope.usersLoader = if $scope.poll.isActive()
      new RecordLoader
        collection: 'memberships'
        path:       'undecided'
        params:     params
    else
      new RecordLoader
        collection: 'poll_did_not_votes'
        params:     params

    $scope.visitorsLoader = new RecordLoader
      collection: 'visitors'
      params:     params

    $scope.moreUsersToLoad = ->
      $scope.usersLoader.numLoaded < $scope.poll.undecidedUserCount

    $scope.moreVisitorsToLoad = ->
      $scope.visitorsLoader.numLoaded < $scope.poll.undecidedVisitorCount

    $scope.showUndecided = ->
      $scope.showingUndecided = true
      $scope.usersLoader.fetchRecords()
      $scope.visitorsLoader.fetchRecords()
