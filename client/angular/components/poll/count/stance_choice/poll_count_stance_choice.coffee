angular.module('loomioApp').directive 'pollCountStanceChoice', ->
  scope: {stanceChoice: '='}
  template: require('./poll_count_stance_choice.haml')
