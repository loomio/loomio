angular.module('loomioApp').directive 'pollCommonPercentVoted', ->
  scope: {poll: '='}
  template: require('./poll_common_percent_voted.haml')
