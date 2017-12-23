Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'pollProposalChartPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/chart_panel/poll_proposal_chart_panel.html'
  controller: ($scope, $translate) ->

    $scope.pollOptionNames = ->
      ['agree', 'abstain', 'disagree', 'block']

    $scope.countFor = (name) ->
      $scope.poll.stanceData[name] or 0

    $scope.translationFor = (name) ->
      $translate.instant("poll_proposal_options.#{name}")
