angular.module('loomioApp').directive 'newMotion', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/new_motion.html'
  replace: true
  link: (scope, element, attrs) ->
