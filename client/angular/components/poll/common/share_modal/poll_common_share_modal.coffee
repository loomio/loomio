EventBus = require 'shared/services/event_bus.coffee'

{ iconFor } = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').factory 'PollCommonShareModal', ->
  templateUrl: 'generated/components/poll/common/share_modal/poll_common_share_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      iconFor($scope.poll)

    EventBus.listen $scope, '$close', $scope.$close
  ]
