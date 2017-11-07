angular.module('loomioApp').directive 'pollCommonStartPoll', ($window, Records, SequenceService, PollService, LmoUrlService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/start_poll/poll_common_start_poll.html'
  controller: ($scope) ->

    $scope.poll.makeAnnouncement = $scope.poll.isNew()
    PollService.applyPollStartSequence $scope
