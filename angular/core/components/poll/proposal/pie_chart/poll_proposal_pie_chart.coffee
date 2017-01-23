angular.module('loomioApp').directive 'pollProposalPieChart', ->
  scope: {myStance: '=', stanceData: '='}
  templateUrl: 'generated/components/poll/proposal/pie_chart/poll_proposal_pie_chart.html'
