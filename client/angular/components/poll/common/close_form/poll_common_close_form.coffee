{ submitForm } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'PollCommonCloseForm', ->
  templateUrl: 'generated/components/poll/common/close_form/poll_common_close_form.html'
  controller: ($scope, poll) ->
    $scope.poll = poll

    $scope.submit = submitForm $scope, poll,
      submitFn: $scope.poll.close
      flashSuccess: "poll_common_close_form.#{$scope.poll.pollType}_closed"
