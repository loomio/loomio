angular.module('loomioApp').directive 'pollCommonAnonymousHelptext', ->
  scope: {poll: '='}
  template: require('./poll_common_anonymous_helptext.haml')
