angular.module('loomioApp').directive 'tinyProposalPieChart', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/mini_proposal_pie_chart/tiny_proposal_pie_chart.html'
  replace: true
  controller: 'MiniProposalPieChartController'
  link: (scope, element, attrs) ->
