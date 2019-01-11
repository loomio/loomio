angular.module('loomioApp').directive 'actionDock', ->
  scope: {actions: '=', model: '='}
  restrict: 'E'
  template: require('./action_dock.haml')
