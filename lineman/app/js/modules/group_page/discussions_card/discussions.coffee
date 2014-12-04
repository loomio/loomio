angular.module('loomioApp').directive 'discussions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/discussions.html'
  replace: true
  controller: 'DiscussionsController'
  link: (scope, element, attrs) ->
