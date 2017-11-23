angular.module('loomioApp').factory 'DiscussionEditModal', (Records, SequenceService) ->
  templateUrl: 'generated/components/discussion/edit_modal/discussion_edit_modal.html'
  controller: ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    SequenceService.applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: (_, discussion) ->
        $scope.announcement = Records.announcements.buildFromModel($scope.discussion, 'discussion_edited')
