angular.module('loomioApp').directive 'helpBubble', ->
  scope: {helptext: '@'}
  restrict: 'E'
  template: require('./help_bubble.haml')
  replace: true
