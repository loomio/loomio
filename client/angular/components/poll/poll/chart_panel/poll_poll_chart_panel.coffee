angular.module('loomioApp').directive 'pollPollChartPanel', ->
  scope: {poll: '='}
  template: require('./poll_poll_chart_panel.haml')
