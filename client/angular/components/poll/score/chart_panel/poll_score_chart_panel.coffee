angular.module('loomioApp').directive 'pollScoreChartPanel', ->
  scope: {poll: '='}
  template: require('./poll_score_chart_panel.haml')
