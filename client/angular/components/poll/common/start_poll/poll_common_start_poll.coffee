Records        = require 'shared/services/records.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'

{ applyPollStartSequence } = require 'angular/helpers/apply.coffee'

angular.module('loomioApp').directive 'pollCommonStartPoll', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/start_poll/poll_common_start_poll.html'
  controller: ($scope) ->

    $scope.poll.makeAnnouncement = $scope.poll.isNew()
    applyPollStartSequence $scope
