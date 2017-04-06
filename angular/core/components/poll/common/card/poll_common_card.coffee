angular.module('loomioApp').directive 'pollCommonCard', (Session, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/card/poll_common_card.html'
  controller: ($scope) ->

    $scope.buttonPressed = false
    $scope.$on 'showResults', ->
      $scope.buttonPressed = true

    $scope.showResults = ->
      $scope.buttonPressed || PollService.hasVoted(Session.participant(), $scope.poll) || $scope.poll.isClosed()

    $scope.$on 'stanceSaved', ->
      $scope.$broadcast 'refreshStance'
