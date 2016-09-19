angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  replace: true
  controller: ($scope, Records, Session, LmoUrlService, FlashService, ModalService, MuteExplanationModal, ThreadService) ->

    $scope.lastVoteByCurrentUser = (thread) ->
      thread.activeProposal().lastVoteByUser(Session.user())

    $scope.muteThread = ->
      ThreadService.mute($scope.thread)

    $scope.unmuteThread = ->
      ThreadService.unmute($scope.thread)

    $scope.translationData = (thread) ->
      position: $scope.lastVoteByCurrentUser(thread).position

    return
