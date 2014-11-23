angular.module('loomioApp').directive 'newVote', ->
  scope: {event: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/new_vote.html'
  replace: true
  controller: 'NewVoteController'
  link: (scope, element, attrs) ->
