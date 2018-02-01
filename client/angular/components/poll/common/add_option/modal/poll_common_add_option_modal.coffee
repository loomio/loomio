Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'

{ listenForLoading } = require 'shared/helpers/listen.coffee'
{ applySequence }    = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').factory 'PollCommonAddOptionModal', ->
  templateUrl: 'generated/components/poll/common/add_option/modal/poll_common_add_option_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: ->
        $scope.announcement = Records.announcements.buildFromModel($scope.poll, 'poll_option_added')

    listenForLoading $scope
  ]
