angular.module('loomioApp').factory 'PollCommonEditModal', (PollService, LoadingService) ->
  templateUrl: 'generated/components/poll/common/edit_modal/poll_common_edit_modal.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    $scope.icon = ->
      PollService.iconFor($scope.poll)

    $scope.$on 'nextStep', $scope.$close
