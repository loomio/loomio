angular.module('loomioApp').factory 'PollCommonUnsubscribeModal', ->
  templateUrl: 'generated/components/poll/common/unsubscribe/modal/poll_common_unsubscribe_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll
  ]
