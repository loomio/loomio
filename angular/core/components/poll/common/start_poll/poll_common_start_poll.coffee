angular.module('loomioApp').directive 'pollCommonStartPoll', ($window, PollService, LmoUrlService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/start_poll/poll_common_start_poll.html'
  controller: ($scope) ->
    $scope.pollTypes = ->
      _.keys PollService.activePollTemplates()

    $scope.iconFor = (pollType) ->
      PollService.fieldFromTemplate(pollType, 'material_icon')

    $scope.editPollType = ->
      $scope.poll.pollType = null
