angular.module('loomioApp').directive 'pollPollActionPanel', (ModalService, Records, PollPollEditVoteModal, PollCommonOutcomeForm) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/poll/action_panel/poll_poll_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.currentUserStance = ->
      $scope.poll.stanceFor(Session.user())
    $scope.myNewStance = Records.stances.build(pollId: $scope.poll.id) unless $scope.currentUserStance()

    $scope.userHasVoted = ->
      $scope.currentUserStance()?

    $scope.openVoteForm = (option) ->
      ModalService.open PollPollEditVoteModal, stance: -> $scope.currentUserStance()
