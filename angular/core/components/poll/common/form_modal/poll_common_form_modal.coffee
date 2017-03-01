angular.module('loomioApp').factory 'PollCommonFormModal', (PollService) ->
  templateUrl: 'generated/components/poll/common/form_modal/poll_common_form_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    $scope.icon = ->
      PollService.iconFor($scope.poll)

    $scope.$on 'pollSaved', $scope.$close
