angular.module('loomioApp').directive 'pollCommonNumberInput', ->
  scope: {model: '=', maxReached: '=?'}
  templateUrl: 'generated/components/poll/common/number_input/poll_common_number_input.html'
  controller: ($scope) ->
    $scope.adjust = (count) -> $scope.model += count
