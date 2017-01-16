angular.module('loomioApp').directive 'pollCheckInChartPanel', (AppConfig, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/check_in/chart_panel/poll_check_in_chart_panel.html'
  controller: ($scope) ->
