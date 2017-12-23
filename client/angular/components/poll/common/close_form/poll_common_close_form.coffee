angular.module('loomioApp').factory 'PollCommonCloseForm', (FormService) ->
  templateUrl: 'generated/components/poll/common/close_form/poll_common_close_form.html'
  controller: ($scope, poll) ->
    $scope.poll = poll

    $scope.submit = FormService.submit $scope, poll,
      submitFn: $scope.poll.close
      flashSuccess: "poll_common_close_form.#{$scope.poll.pollType}_closed"
