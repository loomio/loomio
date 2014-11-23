angular.module('loomioApp').directive 'groupDiscussions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_discussions.html'
  replace: true
  controller: 'GroupDiscussionsController'
  link: (scope, element, attrs) ->
