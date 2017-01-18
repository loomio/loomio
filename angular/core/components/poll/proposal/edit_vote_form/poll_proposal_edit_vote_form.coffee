angular.module('loomioApp').factory 'PollProposalEditVoteForm', ->
  templateUrl: 'generated/components/poll/proposal/edit_vote_form/poll_proposal_edit_vote_form.html'
  controller: ($scope, stance) ->
    $scope.stance = stance.clone()

    $scope.$on '$close', $scope.$close
