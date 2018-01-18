Session  = require 'shared/services/session.coffee'
Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'

{ listenForLoading } = require 'shared/helpers/listen.coffee'
{ myLastStanceFor }  = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonCard', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/card/poll_common_card.html'
  replace: true
  controller: ['$scope', ($scope) ->
    Records.polls.findOrFetchById($scope.poll.key)

    $scope.buttonPressed = false
    EventBus.listen $scope, 'showResults', ->
      $scope.buttonPressed = true

    $scope.showResults = ->
      $scope.buttonPressed || myLastStanceFor($scope.poll)? || $scope.poll.isClosed()

    EventBus.listen $scope, 'stanceSaved', ->
      EventBus.broadcast $scope, 'refreshStance'

    listenForLoading $scope
  ]
