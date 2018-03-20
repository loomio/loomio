Records = require 'shared/services/records.coffee'

{ applySequence } = require 'shared/helpers/apply.coffee'
{ iconFor }       = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').factory 'PollCommonReopenModal', ->
  templateUrl: 'generated/components/poll/common/reopen/modal/poll_common_reopen_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      iconFor($scope.poll)
  ]
