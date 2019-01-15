angular.module('loomioApp').directive 'pollCommonAddOptionForm', ->
  scope: {poll: '='}
  template: require('./poll_common_add_option_form.haml')
  replace: true
