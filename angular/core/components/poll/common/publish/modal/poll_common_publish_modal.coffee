angular.module('loomioApp').factory 'PollCommonPublishModal', (PollService) ->
  templateUrl: 'generated/components/poll/common/publish/modal/poll_common_publish_modal.html'
  controller: ($scope, poll, community, back) ->
    $scope.poll      = poll
    $scope.community = community
    $scope.back      = back

    $scope.icon = ->
      PollService.iconFor($scope.poll)

    $scope.$on 'createComplete', $scope.$close
