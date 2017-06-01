angular.module('loomioApp').factory 'PollCommonShareModal', (PollService) ->
  templateUrl: 'generated/components/poll/common/share_modal/poll_common_share_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.$on '$close', $scope.$close

    $scope.icon = ->
      PollService.iconFor($scope.poll)
