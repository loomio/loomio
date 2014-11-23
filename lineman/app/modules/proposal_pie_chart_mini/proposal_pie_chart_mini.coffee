angular.module('loomioApp').directive 'proposalPieChartMini', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/proposal_pie_chart_mini.html'
  replace: true
  controller: 'ProposalPieChartMiniController'
  link: (scope, element, attrs) ->
