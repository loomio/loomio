Session = require 'shared/services/session.coffee'

angular.module('loomioApp').directive 'pollCommonChartPreview', (PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/chart_preview/poll_common_chart_preview.html'
  controller: ($scope) ->
    $scope.chartType = ->
      PollService.fieldFromTemplate($scope.poll.pollType, 'chart_type')

    $scope.myStance = ->
      PollService.lastStanceBy(Session.user(), $scope.poll)
