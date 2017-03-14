angular.module('loomioApp').factory 'PollCommonStartModal', ($window, PollService, LmoUrlService, Records) ->
  templateUrl: 'generated/components/poll/common/start_modal/poll_common_start_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.$on 'pollSaved', (event, pollKey) ->
      $window.location = LmoUrlService.poll(Records.polls.find(pollKey), {share: true})

    $scope.icon = ->
      PollService.iconFor($scope.poll)
