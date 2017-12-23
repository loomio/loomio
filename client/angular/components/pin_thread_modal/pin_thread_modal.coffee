{ submitForm } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'PinThreadModal', ->
  templateUrl: 'generated/components/pin_thread_modal/pin_thread_modal.html'
  controller: ($scope, thread) ->
    $scope.thread = thread

    $scope.submit = submitForm $scope, $scope.thread,
      submitFn: $scope.thread.savePin
      flashSuccess: "discussion.pin.pinned"
