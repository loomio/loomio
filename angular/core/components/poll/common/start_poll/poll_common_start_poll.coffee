angular.module('loomioApp').directive 'pollCommonStartPoll', (PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/start_poll/poll_common_start_poll.html'
  controller: ($scope) ->
    $scope.pollTypes = ->
      _.keys PollService.activePollTemplates()

    $scope.fieldFromTemplate = (pollType, field) ->
      PollService.fieldFromTemplate(pollType, field)
