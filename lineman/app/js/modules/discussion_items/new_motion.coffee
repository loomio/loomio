angular.module('loomioApp').directive 'newMotion', ->
  scope: {event: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/new_motion.html'
  replace: true
  controller: 'NewMotionController'
  link: (scope, element, attrs) ->
