angular.module('loomioApp').directive 'pollCommonUndecidedPanel', ($location, Records, RecordLoader, AbilityService, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/undecided/panel/poll_common_undecided_panel.html'
  controller: ($scope) ->

    $scope.canShowUndecided = ->
      $scope.poll.undecidedUserCount > 0 and !$scope.showingUndecided

    params =
      poll_id:          $scope.poll.key
      invitation_token: $location.search().invitation_token

    $scope.undecidedLoader = if $scope.poll.isActive()
      new RecordLoader
        collection: 'users'
        params: _.merge(params, {undecided: true})
    else
      new RecordLoader
        collection: 'poll_did_not_votes'
        params: params

    $scope.moreUsersToLoad = ->
      $scope.undecidedLoader.numLoaded < $scope.poll.undecidedUserCount

    $scope.showUndecided = ->
      $scope.showingUndecided = true
      $scope.undecidedLoader.fetchRecords()
