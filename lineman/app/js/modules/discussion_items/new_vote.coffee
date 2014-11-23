angular.module('loomioApp').directive 'newVote', ->
  scope: {vote: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/new_vote.html'
  replace: true
  link: (scope, element, attrs) ->
