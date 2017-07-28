angular.module('loomioApp').directive 'pollCommonUndecidedPanel', ($location, Records, RecordLoader, AbilityService, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/undecided/panel/poll_common_undecided_panel.html'
  controller: ($scope) ->

    $scope.canShowUndecided = ->
      $scope.poll.undecidedUserCount > 0 and !$scope.showingUndecided

    params =
      poll_id:          $scope.poll.key
      invitation_token: $location.search().invitation_token

    $scope.loaders = if $scope.poll.isActive()
      memberships: new RecordLoader
        collection: if $scope.poll.isActive() then 'memberships' else 'poll_did_not_votes'
        path: 'undecided'
        params: params
      invitations: new RecordLoader
        collection: 'invitations'
        path: 'pending'
        params: params

    $scope.canSharePoll = ->
      AbilityService.canSharePoll($scope.poll)

    $scope.moreMembershipsToLoad = ->
      $scope.loaders.memberships.numLoaded < $scope.poll.undecidedUserCount

    $scope.moreInvitationsToLoad = ->
      $scope.canSharePoll() and
      $scope.loaders.invitations.numLoaded < $scope.poll.guestGroup().pendingInvitationsCount

    $scope.moreToLoad = ->
      $scope.moreMembershipsToLoad() or $scope.moreInvitationsToLoad()

    $scope.showUndecided = ->
      $scope.showingUndecided = true
      $scope.loadMore()

    $scope.loadMore = ->
      if $scope.moreMembershipsToLoad()
        $scope.loaders.memberships.fetchRecords()
      else if $scope.moreInvitationsToLoad()
        $scope.loaders.invitations.fetchRecords()
