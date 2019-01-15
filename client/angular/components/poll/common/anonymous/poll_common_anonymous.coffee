angular.module('loomioApp').directive 'pollCommonAnonymous', ->
  scope: {poll: '='}
  template: require('./poll_common_anonymous.haml')
