Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ listenForLoading } = require 'shared/helpers/listen'
{ applySequence }    = require 'shared/helpers/apply'

angular.module('loomioApp').factory 'PollCommonAddOptionModal', ->
  template: require('./poll_common_add_option_modal.haml')
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()
    EventBus.listen $scope, 'pollOptionsAdded',  $scope.$close

    listenForLoading $scope
  ]
