angular.module('loomioApp').directive 'pollRankedChoiceStanceChoice', ->
  scope: {stanceChoice: '='}
  template: require('./poll_ranked_choice_stance_choice.haml')
