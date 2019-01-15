angular.module('loomioApp').directive 'pollPollStanceChoice', ->
  scope: {stanceChoice: '='}
  template: require('./poll_poll_stance_choice.haml')
