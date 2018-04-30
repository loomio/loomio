Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
RecordLoader   = require 'shared/services/record_loader.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').directive 'pollCommonUndecidedPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/undecided/panel/poll_common_undecided_panel.html'
  controller: ['$scope', ($scope) ->

    $scope.canShowUndecided = ->
      !$scope.showingUndecided and
      !$scope.poll.anonymous and
      ($scope.poll.undecidedUserCount > 0 or
      ($scope.poll.guestGroup() || {}).pendingInvitationsCount > 0)

    params =
      poll_id:          $scope.poll.key

    $scope.loaders =
      memberships: new RecordLoader
        collection: if $scope.poll.isActive() then 'memberships' else 'poll_did_not_votes'
        path:       if $scope.poll.isActive() then 'undecided' else ''
        params: params

    $scope.canEditPoll = ->
      AbilityService.canEditPoll($scope.poll)

    $scope.showUndecided = ->
      $scope.showingUndecided = true
      $scope.loaders.memberships.fetchRecords()

    $scope.moreMembershipsToLoad = ->
      $scope.loaders.memberships.numLoaded < $scope.poll.undecidedUserCount

    $scope.loadMemberships = ->
      $scope.loaders.memberships.loadMore()
  ]
