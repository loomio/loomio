angular.module('loomioApp').directive 'pollCommonCard', (Session, Records, LoadingService, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/card/poll_common_card.html'
  replace: true
  controller: ($scope) ->
    Records.polls.findOrFetchById($scope.poll.key) unless $scope.poll.complete

    $scope.buttonPressed = false
    $scope.$on 'showResults', ->
      $scope.buttonPressed = true

    LoadingService.listenForLoading $scope

    $scope.showResults = ->
      $scope.buttonPressed || PollService.hasVoted(Session.user(), $scope.poll) || $scope.poll.isClosed()

    $scope.$on 'stanceSaved', ->
      $scope.$broadcast 'refreshStance'
