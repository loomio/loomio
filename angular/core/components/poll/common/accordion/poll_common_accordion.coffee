angular.module('loomioApp').directive 'pollCommonAccordion', ->
  scope: {pollCollection: '=', selectedPollId: '=?'}
  replace: true
  templateUrl: 'generated/components/poll/common/accordion/poll_common_accordion.html'
  controller: ($scope) ->

    $scope.selectPoll = (poll) ->
      $scope.selectedPollId = poll.id
