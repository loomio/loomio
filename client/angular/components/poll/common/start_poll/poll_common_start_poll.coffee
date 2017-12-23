
Records        = require 'shared/services/records.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').directive 'pollCommonStartPoll', ($window, SequenceService, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/start_poll/poll_common_start_poll.html'
  controller: ($scope) ->

    $scope.poll.makeAnnouncement = $scope.poll.isNew()
    PollService.applyPollStartSequence $scope
