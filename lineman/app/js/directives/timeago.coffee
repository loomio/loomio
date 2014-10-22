angular.module('loomioApp').directive 'timeago', ->
  scope: {timestamp: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/timestamp.html'
  replace: true
  link: (scope, element, attrs) ->