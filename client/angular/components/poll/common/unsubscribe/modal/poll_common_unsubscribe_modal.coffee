angular.module('loomioApp').factory 'PollCommonUnsubscribeModal', ->
  template: require('./poll_common_unsubscribe_modal.haml')
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll
  ]
