angular.module('loomioApp').factory 'PollCommonCloseForm', ->
  templateUrl: 'generated/components/poll/common/close_form/poll_common_close_form.html'
  controller: ($scope, poll, FormService) ->

    $scope.submit = FormService.submit $scope, poll,
      submitFn: poll.close
      flashSuccess: 'poll_close_form.messages.success'
