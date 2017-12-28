Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
RecordLoader   = require 'shared/services/record_loader.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').directive 'pollCommonUndecidedPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/undecided/panel/poll_common_undecided_panel.html'
  controller: ($scope) ->

    $scope.canShowUndecided = ->
      !$scope.showingUndecided and
      !$scope.poll.anonymous and
      ($scope.poll.undecidedUserCount > 0 or
      ($scope.poll.guestGroup() || {}).pendingInvitationsCount > 0)

    params =
      poll_id:          $scope.poll.key
      invitation_token: LmoUrlService.params().invitation_token

    $scope.loaders =
      memberships: new RecordLoader
        collection: if $scope.poll.isActive() then 'memberships' else 'poll_did_not_votes'
        path:       if $scope.poll.isActive() then 'undecided' else ''
        params: params
      invitations: new RecordLoader
        collection: 'invitations'
        path: 'pending'
        params: params

    $scope.canSharePoll = ->
      AbilityService.canSharePoll($scope.poll)

    $scope.showUndecided = ->
      $scope.showingUndecided = true
      if $scope.moreMembershipsToLoad()
        $scope.loaders.memberships.fetchRecords()
      else
        $scope.loaders.invitations.fetchRecords()

    $scope.moreMembershipsToLoad = ->
      $scope.loaders.memberships.numLoaded < $scope.poll.undecidedUserCount

    $scope.moreInvitationsToLoad = ->
      $scope.canSharePoll() and
      $scope.loaders.invitations.numLoaded < $scope.poll.guestGroup().pendingInvitationsCount

    $scope.loadMemberships = ->
      $scope.loaders.memberships.loadMore()

    $scope.loadInvitations = ->
      $scope.loaders.invitations.loadMore()
