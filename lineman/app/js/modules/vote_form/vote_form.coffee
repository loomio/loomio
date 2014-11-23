angular.module('loomioApp').directive 'voteForm', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/vote_form.html'
  replace: true
  controller: 'VoteFormController'
  link: (scope, element, attrs) ->
