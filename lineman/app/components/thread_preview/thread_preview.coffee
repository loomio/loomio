angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  replace: true
  controller: ($scope, Records, CurrentUser, LmoUrlService, FlashService) ->
    $scope.lastVoteByCurrentUser = (thread) ->
      thread.activeProposal().lastVoteByUser(CurrentUser)

    $scope.changeVolume = (volume) ->
      $scope.previousVolume = $scope.thread.volume
      $scope.thread.volume = volume
      $scope.thread.changeVolume($scope.thread.volume).then ->
        FlashService.success "discussion.volume.#{volume}_message",
          name: $scope.thread.title
        , 'undo', $scope.undo

    $scope.undo = -> $scope.changeVolume($scope.previousVolume)

    return
