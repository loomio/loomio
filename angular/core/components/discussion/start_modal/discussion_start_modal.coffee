angular.module('loomioApp').factory 'DiscussionStartModal', (Records, SequenceService) ->
  templateUrl: 'generated/components/discussion/start_modal/discussion_start_modal.html'
  controller: ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    SequenceService.applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: (_, discussion) ->
        $scope.announcement = Records.announcements.buildFromModel(discussion)
