angular.module('loomioApp').factory 'KeyEventService', ($rootScope) ->
  new class KeyEventService

    keyboardShortcuts:
      75:  { event: 'pressedK', key: 'K' }
      27:  { event: 'pressedEsc', key: 'ESC' }
      191: { event: 'pressedSlash', key: '/' }
      38:  { event: 'pressedUpArrow', key: '↑' }
      40:  { event: 'pressedDownArrow', key: '↓' }

    broadcast: (event) ->
      if shortcut = @keyboardShortcuts[event.which]
        $rootScope.$broadcast shortcut.event, angular.element(document.activeElement)[0]

    registerKeyEvent: (scope, eventCode, execute, shouldExecute) ->
      shouldExecute = shouldExecute or @defaultShouldExecute
      scope.$on eventCode, (event, active) ->
        if shouldExecute(active)
          event.preventDefault()
          execute(active)

    defaultShouldExecute: (active = {}) ->
      !_.contains ['INPUT', 'TEXTAREA', 'SELECT'], active.nodeName
