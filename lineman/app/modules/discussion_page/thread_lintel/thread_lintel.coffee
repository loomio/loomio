angular.module('loomioApp').directive 'threadLintel', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/discussion_page/thread_lintel/thread_lintel.html'
  replace: true
  link: (scope, element, attrs) ->
