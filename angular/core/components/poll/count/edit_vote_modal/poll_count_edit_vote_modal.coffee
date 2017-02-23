angular.module('loomioApp').factory 'PollCountEditVoteModal', ->
  templateUrl: 'generated/components/poll/count/edit_vote_modal/poll_count_edit_vote_modal.html'
  controller: ($scope, stance) ->
    $scope.stance = stance.clone()

    $scope.$on 'stanceSaved', $scope.$close
