angular.module('loomioApp').directive 'pollProposalChartPreview', ->
  scope: {myStance: '=', stanceCounts: '='}
  template: require('./poll_proposal_chart_preview.haml')
