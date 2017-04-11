angular.module('loomioApp').directive 'pollCommonFormActions', () ->
  scope: {submit: '=', back: '=', poll: '='}
  templateUrl: 'generated/components/poll/common/form_actions/poll_common_form_actions.html'
