angular.module('loomioApp').directive 'timeago', ->
  scope: {timestamp: '='}
  restrict: 'E'
  templateUrl: 'generated/components/timeago/timeago.html'
  replace: true
  link: (scope, element, attrs) ->
