AppConfig      = require 'shared/services/app_config.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

# a series of method related to the user entering input through the keyboard,
# such as hotkeys or submit on enter
module.exports =
  broadcastKeyEvent: (scope, event) ->
    key = keyboardShortcuts[event.which]
    if key == 'pressedEnter' or (key and !event.ctrlKey and !event.metaKey)
      EventBus.broadcast scope, key, event, document.activeElement

  registerKeyEvent: (scope, eventCode, execute, shouldExecute) ->
    registerKeyEvent(scope, eventCode, execute, shouldExecute)

  registerHotkeys: (scope, hotkeys) ->
    _.each hotkeys, (execute, key) =>
      registerKeyEvent scope, key, execute, (event) ->
        defaultShouldExecute(event) and !AppConfig.currentModal and AbilityService.isLoggedIn()

  submitOnEnter: (scope, opts = {}) ->
    registerKeyEvent scope, 'pressedEnter', scope[opts.submitFn or 'submit'], (active, event) =>
      !scope.isDisabled and
      !scope.submitIsDisabled and
      hasActiveElement(opts.element, active) and
      (event.ctrlKey or event.metaKey or opts.anyEnter) and
      _.contains(active.classList, 'lmo-primary-form-input')

keyboardShortcuts =
  73:  'pressedI'
  71:  'pressedG'
  80:  'pressedP'
  84:  'pressedT'
  27:  'pressedEsc'
  13:  'pressedEnter'
  191: 'pressedSlash'
  38:  'pressedUpArrow'
  40:  'pressedDownArrow'

# NB: only works for textareas at the moment, since we're interested
# in textarea-only forms (comment and vote) submitting only the active form.
# will need to do some additional thinking if we want to support input checking here.
# For non-textarea forms (poll, group, discussion, etc.), this simply always returns true.
hasActiveElement = (element, active) ->
  return true unless element
  _.find element.find('textarea'), (input) -> active == input

defaultShouldExecute = (active = {}, event = {}) ->
  !event.ctrlKey and !event.altKey and !_.contains(['INPUT', 'TEXTAREA', 'SELECT'], active.nodeName)

registerKeyEvent = (scope, eventCode, execute, shouldExecute) ->
  scope["#{eventCode}Event"]() if typeof scope["#{eventCode}Event"] is 'function'
  shouldExecute = shouldExecute or defaultShouldExecute
  # TODO: I'm a little wary of the fact that there's 2 events here,
  # (the one now called 'frameworkEvent' was 'angularEvent'.
  # Something to keep an eye on when using in other frameworks
  scope["#{eventCode}Event"] = EventBus.listen scope, eventCode, (frameworkEvent, originalEvent, active) ->
    if shouldExecute(active, originalEvent)
      frameworkEvent.preventDefault() and originalEvent.preventDefault()
      execute(active, originalEvent)
