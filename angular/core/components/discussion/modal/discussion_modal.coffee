angular.module('loomioApp').factory 'DiscussionModal', ->
  templateUrl: 'generated/components/discussion/modal/discussion_modal.html'
  controller: ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    $scope.$on 'discussionSaved', ->
      $scope.$close()
