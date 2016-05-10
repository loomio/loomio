angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  replace: true
  controller: ($scope, Records, Session, LmoUrlService, FlashService, ModalService, MuteExplanationModal) ->
    $scope.lastVoteByCurrentUser = (thread) ->
      thread.activeProposal().lastVoteByUser(Session.user())

    $scope.changeVolume = (volume) ->
      if !Session.user().hasMuted
        Session.user().update(hasMuted: true)
        Records.users.updateProfile(Session.user()).then ->
          ModalService.open MuteExplanationModal, thread: -> $scope.thread
      else
        $scope.previousVolume = $scope.thread.volume()
        $scope.thread.saveVolume(volume).then ->
          FlashService.success "discussion.volume.#{volume}_message",
            name: $scope.thread.title
          , 'undo', $scope.undo

    $scope.undo = -> $scope.changeVolume($scope.previousVolume)

    $scope.translationData = (thread) ->
      position: $scope.lastVoteByCurrentUser(thread).position

    return
