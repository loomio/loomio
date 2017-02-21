angular.module('loomioApp').factory 'PollPollEditVoteModal', ->
  templateUrl: 'generated/components/poll/poll/edit_vote_modal/poll_poll_edit_vote_modal.html'
  controller: ($scope, stance) ->
    $scope.stance = stance.clone()

    $scope.$on 'stanceSaved', $scope.$close
