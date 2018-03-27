Records = require 'shared/services/records.coffee'

{ iconFor }                = require 'shared/helpers/poll.coffee'
{ applyPollStartSequence } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').factory 'PollCommonStartModal', ->
  templateUrl: 'generated/components/poll/common/start_modal/poll_common_start_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      iconFor($scope.poll)

    applyPollStartSequence $scope,
      afterSaveComplete: (event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
