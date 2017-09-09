angular.module('loomioApp').factory 'DiscussionModal', ->
  templateUrl: 'generated/components/discussion/modal/discussion_modal.html'
  controller: ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    # $scope.currentStep = 'create'
    #
    # $scope.$on 'createComplete', (event, group) ->
    #   if !$scope.group.isNew() or $scope.group.parentId
    #     $scope.$close()
    #   else
    #     $scope.group = group
    #     $scope.currentStep = 'invite'

    # $scope.$on 'inviteComplete', $scope.$close
