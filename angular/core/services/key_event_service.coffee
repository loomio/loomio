angular.module('loomioApp').factory 'KeyEventService', ($rootScope) ->
  new class KeyEventService

    keyboardShortcuts:
      73:  'pressedI'
      71:  'pressedG'
      80:  'pressedP'
      84:  'pressedT'
      27:  'pressedEsc'
      13:  'pressedEnter'
      191: 'pressedSlash'
      38:  'pressedUpArrow'
      40:  'pressedDownArrow'

    broadcast: (event) ->
      key = @keyboardShortcuts[event.which]
      if key == 'pressedEnter' or (key and !event.ctrlKey and !event.metaKey)
        $rootScope.$broadcast key, event, angular.element(document.activeElement)[0]

    registerKeyEvent: (scope, eventCode, execute, shouldExecute) ->
      shouldExecute = shouldExecute or @defaultShouldExecute
      scope.$$listeners[eventCode] = null
      scope.$on eventCode, (angularEvent, originalEvent, active) ->
        if shouldExecute(active, originalEvent)
          angularEvent.preventDefault() and originalEvent.preventDefault()
          execute(active, originalEvent)

    defaultShouldExecute: (active = {}, event = {}) ->
      !event.ctrlKey and !event.altKey and !_.contains(['INPUT', 'TEXTAREA', 'SELECT'], active.nodeName)

    submitOnEnter: (scope) ->
      @previousScope.$$listeners['pressedEnter'] = null if @previousScope?
      @previousScope = scope
      @registerKeyEvent scope, 'pressedEnter', scope.submit, (active, event) =>
        !scope.isDisabled and
        !scope.submitIsDisabled and
        (event.ctrlKey or event.metaKey) and
        _.contains(active.classList, 'lmo-primary-form-input')
