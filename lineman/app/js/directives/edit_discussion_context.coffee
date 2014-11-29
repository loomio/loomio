angular.module('loomioApp').directive 'editDiscussionContext', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/edit_discussion_context.html'
  replace: true
  controller: 'DiscussionInlineFormController'
  link: (scope, element, attrs) ->
