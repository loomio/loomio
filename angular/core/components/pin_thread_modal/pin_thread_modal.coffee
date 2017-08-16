angular.module('loomioApp').factory 'PinThreadModal', (FormService) ->
  templateUrl: 'generated/components/pin_thread_modal/pin_thread_modal.html'
  controller: ($scope, thread) ->
    $scope.thread = thread

    $scope.submit = FormService.submit $scope, $scope.thread,
      submitFn: $scope.thread.savePin
      flashSuccess: "discussion.pin.pinned"
