angular.module('loomioApp').directive 'starToggle', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/star_toggle/star_toggle.html'
  replace: true
