angular.module('loomioApp').directive 'pollCommonReopenForm', ->
  scope: {poll: '='}
  template: require('./poll_common_reopen_form.haml')
