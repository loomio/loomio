angular.module('loomioApp').directive 'pollDotVoteStanceChoice', (PollService) ->
  scope: {stanceChoice: '='}
  templateUrl: 'generated/components/poll/dot_vote/stance_choice/poll_dot_vote_stance_choice.html'
  controller: ($scope) ->
