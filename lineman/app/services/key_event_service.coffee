angular.module('loomioApp').factory 'KeyEventService', ->
  new class KeyEventService

    setKeyEvent: (scope, eventCode, eventFn, shouldExecute) ->
      shouldExecute = shouldExecute or @defaultShouldExecute
      scope.$on eventCode, (event, active) ->
        if shouldExecute(active)
          event.preventDefault()
          eventFn(active, event)

    defaultShouldExecute: (active = {}) ->
      !_.contains ['INPUT', 'TEXTAREA', 'SELECT'], active.nodeName
