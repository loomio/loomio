AppConfig = require 'shared/services/app_config.coffee'
EventBus  = require 'shared/services/event_bus.coffee'

# a series of method related to the user entering input through the keyboard,
# such as hotkeys or submit on enter
module.exports =
  broadcastKeyEvent: ($scope, event) ->
    key = keyboardShortcuts[event.which]
    if key == 'pressedEnter' or (key and !event.ctrlKey and !event.metaKey)
      EventBus.broadcast $scope, key, event, angular.element(document.activeElement)[0]

  registerKeyEvent: ($scope, eventCode, execute, shouldExecute) ->
    registerKeyEvent($scope, eventCode, execute, shouldExecute)

  registerHotkeys: ($scope, hotkeys) ->
    _.each hotkeys, (execute, key) =>
      registerKeyEvent $scope, key, execute, (event) ->
        defaultShouldExecute(event) and !AppConfig.currentModal

  submitOnEnter: ($scope, opts = {}) ->
    previousScope.$$listeners['pressedEnter'] = null if @previousScope?
    previousScope = $scope
    registerKeyEvent $scope, 'pressedEnter', $scope[opts.submitFn or 'submit'], (active, event) =>
      !$scope.isDisabled and
      !$scope.submitIsDisabled and
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

previousScope = null
defaultShouldExecute = (active = {}, event = {}) ->
  !event.ctrlKey and !event.altKey and !_.contains(['INPUT', 'TEXTAREA', 'SELECT'], active.nodeName)

registerKeyEvent = ($scope, eventCode, execute, shouldExecute) ->
  shouldExecute = shouldExecute or defaultShouldExecute
  $scope.$$listeners[eventCode] = null
  EventBus.listen $scope, eventCode, (angularEvent, originalEvent, active) ->
    if shouldExecute(active, originalEvent)
      angularEvent.preventDefault() and originalEvent.preventDefault()
      execute(active, originalEvent)
