angular.module('loomioApp').directive 'group_discussions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_discussions.html'
  replace: true
  controller: 'GroupDiscussionsController'
  link: (scope, element, attrs) ->
