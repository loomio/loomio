angular.module('loomioApp').directive 'proposalPieChart', ->
  scope: {proposal: '=', size: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposals_card/proposal_pie_chart/proposal_pie_chart.html'
  replace: true
  controller: 'ProposalPieChartController'
