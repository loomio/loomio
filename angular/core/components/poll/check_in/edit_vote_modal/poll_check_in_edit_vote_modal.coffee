angular.module('loomioApp').factory 'PollCheckInEditVoteModal', ->
  templateUrl: 'generated/components/poll/check_in/edit_vote_modal/poll_check_in_edit_vote_modal.html'
  controller: ($scope, stance) ->
    $scope.stance = stance.clone()

    $scope.$on 'stanceSaved', $scope.$close
