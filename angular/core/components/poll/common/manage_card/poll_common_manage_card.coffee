angular.module('loomioApp').directive 'pollCommonManageCard', ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/manage_card/poll_common_manage_card.html'
  controller: ($scope) ->
