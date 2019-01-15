angular.module('loomioApp').directive 'pollDotVoteChartPanel', ->
  scope: {poll: '='}
  template: require('./poll_dot_vote_chart_panel.haml')
