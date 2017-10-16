angular.module('loomioApp').factory 'PollCommonStartModal', ($location, PollService, LmoUrlService, LoadingService, Records) ->
  templateUrl: 'generated/components/poll/common/start_modal/poll_common_start_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      PollService.iconFor($scope.poll)

    $scope.$on '$close', $scope.$close
