angular.module('loomioApp').factory 'PollCloseForm', ->
  templateUrl: 'generated/components/poll/close_form/poll_close_form.html'
  controller: ($scope, poll, FormService) ->

    $scope.submit = FormService.submit $scope, poll,
      submitFn: poll.close
      flashSuccess: 'poll_close_form.messages.success'
