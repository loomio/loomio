angular.module('loomioApp').directive 'pollCommonPublishForm', (PollService, FlashService) ->
  scope: {poll: '=', community: '=', back: '=?'}
  templateUrl: 'generated/components/poll/common/publish/form/poll_common_publish_form.html'
  controller: ($scope) ->

    $scope.submit = ->
      $scope.poll.publish($scope.community, $scope.message).then ->
        FlashService.success 'poll_common_publish_form.published'
        $scope.back() if $scope.back
