angular.module('loomioApp').directive 'pollCommonCloseForm', ->
  scope: {poll: '='}
  template: require('./poll_common_close_form.haml')
