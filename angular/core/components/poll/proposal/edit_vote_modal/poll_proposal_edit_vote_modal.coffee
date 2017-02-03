angular.module('loomioApp').factory 'PollProposalEditVoteModal', ->
  templateUrl: 'generated/components/poll/proposal/edit_vote_modal/poll_proposal_edit_vote_modal.html'
  controller: ($scope, stance) ->
    $scope.stance = stance.clone()

    $scope.$on 'stanceSaved', $scope.$close
