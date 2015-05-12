angular.module('loomioApp').directive 'tinyProposalPieChart', ($timeout) ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/mini_proposal_pie_chart/tiny_proposal_pie_chart.html'
  replace: true
  controller: 'MiniProposalPieChartController'
  link: (scope, element, attrs) ->
    $timeout (-> scope.canLoadPie = true), 0
