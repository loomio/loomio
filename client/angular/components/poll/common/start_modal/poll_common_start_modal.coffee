Records = require 'shared/services/records'

{ iconFor }                = require 'shared/helpers/poll'
{ applyPollStartSequence } = require 'shared/helpers/apply'

angular.module('loomioApp').factory 'PollCommonStartModal', ->
  template: require('./poll_common_start_modal.haml')
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      iconFor($scope.poll)

    applyPollStartSequence $scope,
      afterSaveComplete: (event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
