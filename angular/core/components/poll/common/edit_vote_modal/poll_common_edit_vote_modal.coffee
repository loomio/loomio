angular.module('loomioApp').factory 'PollCommonEditVoteModal', (PollService) ->
  templateUrl: 'generated/components/poll/common/edit_vote_modal/poll_common_edit_vote_modal.html'
  controller: ($scope, stance) ->
    $scope.stance = stance.clone()
    $scope.stance.visitorAttributes = _.pick($scope.stance.participant().serialize().visitor, 'name', 'email', 'participation_token')

    $scope.$on 'stanceSaved', $scope.$close

    $scope.icon = ->
      PollService.iconFor($scope.stance.poll())
