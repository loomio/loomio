angular.module('loomioApp').directive 'pollCountForm', ->
  scope: {poll: '=', back: '=?'}
  template: require('./poll_count_form.haml')
