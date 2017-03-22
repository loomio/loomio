angular.module('loomioApp').directive 'pollCommonShareForm', ->
  scope: {poll: '=', back: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/form/poll_common_share_form.html'
