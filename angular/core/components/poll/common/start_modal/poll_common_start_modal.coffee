angular.module('loomioApp').factory 'PollCommonStartModal', ($location, Records, PollService) ->
  templateUrl: 'generated/components/poll/common/start_modal/poll_common_start_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      PollService.iconFor($scope.poll)

    PollService.applyPollStartSequence $scope,
      afterSaveComplete: (poll) ->
        $scope.announcement = Records.announcements.buildFromModel(poll)
