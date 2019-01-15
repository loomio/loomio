angular.module('loomioApp').directive 'pollRankedChoiceChartPanel', ->
  scope: {poll: '='}
  template: require('./poll_ranked_choice_chart_panel.haml')
