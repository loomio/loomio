angular.module('loomioApp').directive 'pollProposalPanel', (Session, Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/panel/poll_proposal_panel.html'
  controller: ($scope) ->
    $scope.userHasVoted = ->
      _.any(Records.stances.find(pollId: $scope.poll.id, participantId: Session.user().id))
