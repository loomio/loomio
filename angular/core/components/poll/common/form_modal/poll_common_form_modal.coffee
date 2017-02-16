angular.module('loomioApp').factory 'PollCommonFormModal', ->
  templateUrl: 'generated/components/poll/common/form_modal/poll_common_form_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    $scope.$on 'pollSaved', $scope.$close
