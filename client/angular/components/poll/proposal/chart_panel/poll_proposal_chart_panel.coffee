Records = require 'shared/services/records'
I18n    = require 'shared/services/i18n'

angular.module('loomioApp').directive 'pollProposalChartPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/chart_panel/poll_proposal_chart_panel.html'
  controller: ['$scope', ($scope) ->

    $scope.pollOptionNames = ->
      ['agree', 'abstain', 'disagree', 'block']

    $scope.countFor = (name) ->
      $scope.poll.stanceData[name] or 0

    $scope.percentFor = (name) ->
      parseInt(parseFloat($scope.countFor(name)) / parseFloat($scope.poll.stancesCount) * 100) || 0

    $scope.translationFor = (name) ->
      I18n.t("poll_proposal_options.#{name}")
  ]
