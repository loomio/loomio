Records = require 'shared/services/records'

{ applySequence } = require 'shared/helpers/apply'
{ iconFor }       = require 'shared/helpers/poll'

angular.module('loomioApp').factory 'PollCommonReopenModal', ->
  template: require('./poll_common_reopen_modal.haml')
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      iconFor($scope.poll)
  ]
