angular.module('loomioApp').factory 'DiscussionEditModal', ->
  templateUrl: 'generated/components/discussion/edit_modal/discussion_edit_modal.html'
  controller: ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    $scope.$on 'nextStep', $scope.$close
