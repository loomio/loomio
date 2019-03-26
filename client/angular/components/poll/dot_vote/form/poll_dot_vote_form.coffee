angular.module('loomioApp').directive 'pollDotVoteForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/dot_vote/form/poll_dot_vote_form.html'
  controller: ['$scope', ($scope) ->
    $scope.poll.customFields.dots_per_person = $scope.poll.customFields.dots_per_person or 8
  ]
