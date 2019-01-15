angular.module('loomioApp').directive 'pollCommonStanceReason', ->
  scope: {stance: '='}
  replace: true
  template: require('./poll_common_stance_reason.haml')
