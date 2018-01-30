angular.module('loomioApp').directive 'pollPollForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/poll/form/poll_poll_form.html'
