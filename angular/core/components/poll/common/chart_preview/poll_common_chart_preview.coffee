angular.module('loomioApp').directive 'pollCommonChartPreview', (PollService, Session) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/chart_preview/poll_common_chart_preview.html'
  controller: ($scope) ->
    $scope.chartType = ->
      PollService.fieldFromTemplate($scope.poll.pollType, 'chart_type')

    $scope.myStance = ->
      PollService.lastStanceBy(Session.participant(), $scope.poll)
