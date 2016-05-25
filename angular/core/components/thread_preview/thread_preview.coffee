angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  replace: true
  controller: ($scope, Records, Session, LmoUrlService, FlashService, ModalService, MuteExplanationModal) ->
    $scope.lastVoteByCurrentUser = ->
      $scope.thread.activeProposal().lastVoteByUser(Session.user())

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
      position: $scope.lastVoteByCurrentUser().position

    $scope.voteBackgroundImage = ->
      position = switch $scope.lastVoteByCurrentUser().position
        when 'yes'     then 'agree'
        when 'abstain' then 'abstain'
        when 'no'      then 'disagree'
        when 'block'   then 'block'
      LmoUrlService.backgroundImageFor("/img/#{position}.svg")

    return
