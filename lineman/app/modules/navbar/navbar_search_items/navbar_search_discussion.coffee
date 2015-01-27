angular.module('loomioApp').directive 'navbarSearchDiscussion', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/modules/navbar/navbar_search_items/navbar_search_discussion.html'
  replace: true
  link: (scope, element, attrs) ->
