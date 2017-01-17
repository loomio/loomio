angular.module('loomioApp').directive 'pollCommonAccordion', ->
  scope: {pollCollection: '='}
  templateUrl: 'generated/components/poll/common/accordion/poll_common_accordion.html'
  controller: ($scope) ->
