angular.module('loomioApp').directive 'pollPollActionPanel', ($location, ModalService, Records, PollPollEditVoteModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/poll/action_panel/poll_poll_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.stance = $scope.poll.stanceFor(Session.user()) or
                    Records.stances.build(pollId: $scope.poll.id).choose($location.search().poll_option_id)

    $scope.userHasVoted = ->
      $scope.stance.id

    $scope.openVoteForm = (option) ->
      ModalService.open PollPollEditVoteModal, stance: -> $scope.stance
