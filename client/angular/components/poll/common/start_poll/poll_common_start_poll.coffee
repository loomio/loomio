{ applyPollStartSequence } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').directive 'pollCommonStartPoll', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/start_poll/poll_common_start_poll.html'
  controller: ['$scope', ($scope) ->
    applyPollStartSequence $scope
  ]
