angular.module('loomioApp').directive 'proposalPieChart', ->
  scope: {proposal: '=', size: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_pie_chart/proposal_pie_chart.html'
  replace: true
  controller: 'ProposalPieChartController'
