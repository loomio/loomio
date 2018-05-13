Records = require 'shared/services/records'

{ iconFor }       = require 'shared/helpers/poll'
{ applySequence } = require 'shared/helpers/apply'

angular.module('loomioApp').factory 'PollCommonEditModal', ->
  templateUrl: 'generated/components/poll/common/edit_modal/poll_common_edit_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      iconFor($scope.poll)

    applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: (_, event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
