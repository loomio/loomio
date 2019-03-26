angular.module('loomioApp').directive 'actionDock', ->
  scope: {actions: '=', model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/action_dock/action_dock.html'
