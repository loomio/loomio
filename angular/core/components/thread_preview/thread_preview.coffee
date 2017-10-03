angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  replace: true
  controller: ($scope, Records, Session, LmoUrlService, FlashService, ModalService, DismissExplanationModal, ThreadService, PollService) ->
    $scope.dismiss = ->
      if !Session.user().hasExperienced("dismissThread")
        Records.users.saveExperience("dismissThread")
        ModalService.open DismissExplanationModal, thread: -> $scope.thread
      else
        $scope.thread.dismiss()
        FlashService.success "dashboard_page.thread_dismissed"

    $scope.muteThread = ->
      ThreadService.mute($scope.thread)

    $scope.unmuteThread = ->
      ThreadService.unmute($scope.thread)

    return
