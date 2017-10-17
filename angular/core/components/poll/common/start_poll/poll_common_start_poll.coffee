angular.module('loomioApp').directive 'pollCommonStartPoll', ($window, Records, SequenceService, PollService, LmoUrlService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/start_poll/poll_common_start_poll.html'
  controller: ($scope) ->

    $scope.poll.makeAnnouncement = $scope.poll.isNew()
    SequenceService.applySequence $scope, ['choose', 'save', 'share'],
      initialStep: if $scope.poll.pollType then 'save' else 'choose'
      chooseComplete: (_, pollType) ->
        $scope.poll.pollType = pollType
      saveComplete: (_, poll) ->
        if poll.group() then $scope.$emit '$close' else $scope.poll = poll
      shareComplete: ->
        $scope.$emit '$close'
