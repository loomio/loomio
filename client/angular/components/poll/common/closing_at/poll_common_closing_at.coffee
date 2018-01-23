angular.module('loomioApp').directive 'pollCommonClosingAt', ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/closing_at/poll_common_closing_at.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.time = ->
      key = if $scope.poll.isActive() then 'closingAt' else 'closedAt'
      $scope.poll[key]

    $scope.translationKey = ->
      if $scope.poll.isActive()
        'common.closing_in'
      else
        'common.closed_ago'
  ]
