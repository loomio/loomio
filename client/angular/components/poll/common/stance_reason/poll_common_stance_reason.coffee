angular.module('loomioApp').directive 'pollCommonStanceReason', ->
  scope: {stance: '='}
  replace: true
  templateUrl: 'generated/components/poll/common/stance_reason/poll_common_stance_reason.html'
