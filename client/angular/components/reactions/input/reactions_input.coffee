angular.module('loomioApp').directive 'reactionsInput', ->
  scope: {model: '='}
  restrict: 'E'
  template: require('./reactions_input.haml')
  replace: true
