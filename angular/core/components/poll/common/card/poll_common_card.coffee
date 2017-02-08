angular.module('loomioApp').directive 'pollCommonCard', (Session) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/card/poll_common_card.html'
  controller: ($scope) ->
    $scope.buttonPressed = false
    $scope.press = ->
      $scope.buttonPressed = true

    $scope.showResults = ->
      $scope.buttonPressed || $scope.poll.userHasVoted(Session.user()) || $scope.poll.isClosed()

    $scope.$on 'stanceSaved', ->
      $scope.$broadcast 'refreshStance'
