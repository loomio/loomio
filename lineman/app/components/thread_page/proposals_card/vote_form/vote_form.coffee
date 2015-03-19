angular.module('loomioApp').directive 'voteForm', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/thread_page/proposals_card/vote_form/vote_form.html'
  replace: true
  controller: 'VoteFormController'
  link: (scope, element, attrs) ->
