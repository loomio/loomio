angular.module('loomioApp').directive 'proposalPieChart', ->
  scope: {proposal: '=', size: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/proposal_pie_chart.html'
  replace: true
  controller: 'ProposalPieChartController'
  link: (scope, element, attrs) ->
