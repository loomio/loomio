Records = require 'shared/services/records'

{ applySequence } = require 'shared/helpers/apply'

angular.module('loomioApp').factory 'PollCommonCloseModal', ->
  templateUrl: 'generated/components/poll/common/close/modal/poll_common_close_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    applySequence $scope,
      steps: ['close', 'outcome', 'announce']
      closeComplete: ->
        $scope.outcome = Records.outcomes.build(pollId: $scope.poll.id)
      outcomeComplete: (_, event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)

  ]
