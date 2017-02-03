angular.module('loomioApp').directive 'pollProposalActionPanel', ($location, ModalService, Records, PollProposalEditVoteModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/action_panel/poll_proposal_action_panel.html'
  controller: ($scope, Records, Session) ->
    $scope.stance = $scope.poll.stanceFor(Session.user()) or
                    Records.stances.build(pollId: $scope.poll.id).choose($location.search().poll_option_id)

    $scope.userHasVoted = ->
      $scope.poll.stanceFor(Session.user())

    $scope.openVoteForm = ->
      ModalService.open PollProposalEditVoteModal, stance: -> $scope.stance
