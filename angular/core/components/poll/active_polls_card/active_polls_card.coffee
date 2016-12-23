angular.module('loomioApp').directive 'activePollsCard', ->
  scope: {discussion: '='}
  templateUrl: 'generated/components/poll/active_polls_card/active_polls_card.html'
  controller: ($scope, Records) ->
    Records.polls.fetchByDiscussion($scope.discussion.key, active: true)
