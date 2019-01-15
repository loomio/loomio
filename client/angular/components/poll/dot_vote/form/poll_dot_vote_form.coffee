angular.module('loomioApp').directive 'pollDotVoteForm', ->
  scope: {poll: '='}
  template: require('./poll_dot_vote_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.poll.customFields.dots_per_person = $scope.poll.customFields.dots_per_person or 8
  ]
