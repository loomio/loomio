angular.module('loomioApp').directive 'timeago', ->
  scope: {timestamp: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/timeago.html'
  replace: true
  link: (scope, element, attrs) ->
