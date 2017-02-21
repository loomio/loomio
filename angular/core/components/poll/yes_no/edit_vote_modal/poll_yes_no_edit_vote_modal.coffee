angular.module('loomioApp').factory 'PollYesNoEditVoteModal', ->
  templateUrl: 'generated/components/poll/yes_no/edit_vote_modal/poll_yes_no_edit_vote_modal.html'
  controller: ($scope, stance) ->
    $scope.stance = stance.clone()

    $scope.$on 'stanceSaved', $scope.$close
