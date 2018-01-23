angular.module('loomioApp').directive 'pollCountForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/count/form/poll_count_form.html'
