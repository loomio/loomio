angular.module('loomioApp').factory 'CloseExplanationModal', ->
  templateUrl: 'generated/components/close_explanation_modal/close_explanation_modal.html'
  controller: ($scope, thread, Records, ThreadService) ->
    $scope.thread = thread
    $scope.closeThread = ->
      ThreadService.close($scope.thread).then $scope.$close()
