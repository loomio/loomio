angular.module('loomioApp').directive 'previousPollsCard', ->
  scope: {thread: '=', selectedPollId: '=?'}
  templateUrl: 'generated/components/thread_page/previous_polls_card/previous_polls_card.html'
  controller: ($scope) ->
    $scope.pollCollection =
      polls: -> $scope.thread.closedPolls()
