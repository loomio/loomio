angular.module('loomioApp').directive 'pollMeetingChartPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/meeting/chart_panel/poll_meeting_chart_panel.html'
  controller: ($scope) ->
