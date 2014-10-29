angular.module('loomioApp').directive 'miniProposalPieChart', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/mini_proposal_pie_chart.html'
  replace: true
  controller: 'ProposalPieChartController'
  link: (scope, element, attrs) ->
