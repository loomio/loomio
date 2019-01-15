angular.module('loomioApp').directive 'pollDotVoteStanceChoice', ->
  scope: {stanceChoice: '='}
  template: require('./poll_dot_vote_stance_choice.haml')
