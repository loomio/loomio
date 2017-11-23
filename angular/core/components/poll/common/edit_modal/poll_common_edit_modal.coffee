angular.module('loomioApp').factory 'PollCommonEditModal', (Records, PollService, SequenceService) ->
  templateUrl: 'generated/components/poll/common/edit_modal/poll_common_edit_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.icon = ->
      PollService.iconFor($scope.poll)

    SequenceService.applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: (_, poll) ->
        $scope.announcement = Records.announcements.buildFromModel(poll, 'poll_edited')
