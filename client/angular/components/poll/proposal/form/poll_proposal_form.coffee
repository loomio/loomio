angular.module('loomioApp').directive 'pollProposalForm', ->
  scope: {poll: '='}
  template: require('./poll_proposal_form.haml')
