EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').directive 'pollMeetingChartPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/chart_panel/poll_meeting_chart_panel.html'
  controller: ['$scope', ($scope) ->

    $scope.hasMaybeVotes = () ->
      #IF ANY OF THE STANCE CHOICES HAS A SCORE OF 1 RETURN TRUE
      _.some $scope.poll.stances(), (stance) ->
        _.some stance.stanceChoices(), (choice) ->
          choice.score == 1

    $scope.totalFor = (option) ->
      _.reduce($scope.poll.latestStances(), (total, stance) ->
        scoreForStance = stance.scoreFor(option)
        total[scoreForStance] += 1
        total
      , [0, 0, 0])

    EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
      $scope.zone = zone
  ]
