angular.module('loomioApp').factory 'KeyEventService', ($rootScope) ->
  new class KeyEventService

    keyboardShortcuts:
      73:  'pressedI'
      71:  'pressedG'
      84:  'pressedT'
      27:  'pressedEsc'
      13:  'pressedEnter'
      191: 'pressedSlash'
      38:  'pressedUpArrow'
      40:  'pressedDownArrow'

    broadcast: (event) ->
      if !(event.ctrlKey or event.metaKey) and key = @keyboardShortcuts[event.which]
        $rootScope.$broadcast key, event, angular.element(document.activeElement)[0]

    registerKeyEvent: (scope, eventCode, execute, shouldExecute) ->
      shouldExecute = shouldExecute or @defaultShouldExecute
      scope.$on eventCode, (angularEvent, originalEvent, active) ->
        if shouldExecute(active, originalEvent)
          angularEvent.preventDefault() and originalEvent.preventDefault()
          execute(active)

    defaultShouldExecute: (active = {}, event = {}) ->
      !event.ctrlKey and !event.altKey and !_.contains(['INPUT', 'TEXTAREA', 'SELECT'], active.nodeName)

    submitOnEnter: (scope) ->
      @registerKeyEvent scope, 'pressedEnter', scope.submit, (active, event) =>
        (event.ctrlKey or event.metaKey) and
        angular.element(active).scope() == scope and
        _.contains(active.classList, 'lmo-primary-form-input')
