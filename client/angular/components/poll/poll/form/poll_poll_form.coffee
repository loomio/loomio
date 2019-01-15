angular.module('loomioApp').directive 'pollPollForm', ->
  scope: {poll: '=', back: '=?'}
  template: require('./poll_poll_form.haml')
