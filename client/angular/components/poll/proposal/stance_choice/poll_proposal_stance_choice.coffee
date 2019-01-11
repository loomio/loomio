angular.module('loomioApp').directive 'pollProposalStanceChoice', ->
  scope: {stanceChoice: '='}
  template: require('./poll_proposal_stance_choice.haml')
