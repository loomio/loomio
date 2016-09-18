angular.module('loomioApp').component 'threadPreview',
  bindings: {thread: '='}
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  controller: ($scope, Records, Session, LmoUrlService, FlashService, ModalService, MuteExplanationModal) ->
    $scope.lastVoteByCurrentUser = ->
      $scope.thread.activeProposal().lastVoteByUser(Session.user())

    $scope.changeVolume = (volume) ->
      if !Session.user().hasExperienced("mutingThread")
        Records.users.saveExperience("mutingThread")
        Records.users.updateProfile(Session.user()).then ->
          ModalService.open MuteExplanationModal, thread: -> $scope.thread
      else
        $scope.previousVolume = $scope.thread.volume()
        $scope.thread.saveVolume(volume).then ->
          FlashService.success "discussion.volume.#{volume}_message",
            name: $scope.thread.title
          , 'undo', $scope.undo

    $scope.undo = -> $scope.changeVolume($scope.previousVolume)

    $scope.translationData = ->
      position: $scope.lastVoteByCurrentUser().position

    return
