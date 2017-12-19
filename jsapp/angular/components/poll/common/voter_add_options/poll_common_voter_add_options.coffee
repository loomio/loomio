angular.module('loomioApp').directive 'pollCommonVoterAddOptions', (PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/voter_add_options/poll_common_voter_add_options.html'
  controller: ($scope) ->
    $scope.validPollType = ->
      PollService.fieldFromTemplate($scope.poll.pollType, 'can_add_options')
