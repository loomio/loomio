angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  replace: true
  controller: ($scope, Records, User, LmoUrlService, FlashService, ModalService, MuteExplanationModal) ->
    $scope.lastVoteByCurrentUser = (thread) ->
      thread.activeProposal().lastVoteByUser(User.current())

    $scope.changeVolume = (volume) ->
      if !User.current().hasMuted
        User.current().update(hasMuted: true)
        Records.users.updateProfile(User.current()).then ->
          ModalService.open MuteExplanationModal, thread: -> $scope.thread
      else
        $scope.previousVolume = $scope.thread.volume()
        $scope.thread.saveVolume(volume).then ->
          FlashService.success "discussion.volume.#{volume}_message",
            name: $scope.thread.title
          , 'undo', $scope.undo

    $scope.undo = -> $scope.changeVolume($scope.previousVolume)

    return
