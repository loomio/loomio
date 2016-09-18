angular.module('loomioApp').factory 'DismissExplanationModal', ->
  templateUrl: 'generated/components/dismiss_explanation_modal/dismiss_explanation_modal.html'
  controller: ($scope, thread, Records, FlashService) ->
    $scope.thread = thread

    $scope.dismiss = ->
      $scope.thread.dismiss()
      FlashService.success('dashboard_page.thread_dismissed')
      $scope.$close()
