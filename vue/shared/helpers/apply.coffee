EventBus      = require 'shared/services/event_bus'
LmoUrlService = require 'shared/services/lmo_url_service'
Session       = require 'shared/services/session'
AppConfig   = require 'shared/services/app_config'

# a series of helpers which attaches functionality to a scope, such as performing
# a sequence of steps, or loading for a particular function
obeyMembersCanAnnounce = (steps, group) ->
  if Session.user().isAdminOf?(group) or (group && group.membersCanAnnounce)
    steps
  else
    _.without(steps, 'announce')

module.exports =
  obeyMembersCanAnnounce: obeyMembersCanAnnounce
  applyLoadingFunction: (scope, functionName) ->
    executing = "#{functionName}Executing"
    loadingFunction = scope[functionName]
    scope[functionName] = (args...) ->
      return if scope[executing]
      scope[executing] = true
      loadingFunction(args...).finally -> scope[executing] = false

  applySequence: (scope, options = {}) ->
    applySequence(scope, options)

  applyPollStartSequence: (scope, options = {}) ->
    applySequence scope,
      steps: obeyMembersCanAnnounce(['choose', 'save', 'announce'], scope.poll.group())
      initialStep: if scope.poll.pollType then 'save' else 'choose'
      emitter: options.emitter or scope
      chooseComplete: (_, pollType) ->
        scope.poll.pollType = pollType
      saveComplete: (_, event) ->
        LmoUrlService.goTo LmoUrlService.poll(event.model())
        options.afterSaveComplete(event) if typeof options.afterSaveComplete is 'function'

  applyDiscussionStartSequence: (scope, options = {}) ->
    steps = if AppConfig.theme['dont_notify_new_thread']
      ['save']
    else
      ['save', 'announce']

    applySequence scope,
      steps: obeyMembersCanAnnounce(['save', 'announce'], scope.discussion.group())
      emitter: options.emitter or scope
      saveComplete: (_, event) ->
        LmoUrlService.goTo LmoUrlService.discussion(event.model())
        options.afterSaveComplete(event) if typeof options.afterSaveComplete is 'function'

applySequence = (scope, options) ->
  scope.steps = if typeof options.steps is 'function' then options.steps() else options.steps
  scope.currentStep = options.initialStep or _.head(scope.steps)

  scope.currentStepIndex = -> _.indexOf scope.steps, scope.currentStep

  scope.progress = ->
    return unless scope.steps.length > 1
    100 * parseFloat(scope.currentStepIndex()) / (scope.steps.length - 1)

  emitter = options.emitter or scope

  # deregister old listeners if they're present
  emitter.unlistenPrevious() if typeof emitter.unlistenPrevious is 'function'
  emitter.unlistenNext()     if typeof emitter.unlistenNext     is 'function'
  emitter.unlistenSkip()     if typeof emitter.skipNext         is 'function'

  changeStep = (incr, name) ->
    (args...) ->
      scope.isDisabled = false unless options.keepDisabled
      # perform a callback if its specified
      (options["#{scope.currentStep}#{name}"] or ->)(args...)
      scope.currentStep = scope.steps[scope.currentStepIndex() + incr]
      # don't bubble the event
      args[0].stopPropagation() if typeof (args[0] or {}).stopPropagation is 'function'
      # emit a close event if we've run out of steps
      EventBus.emit emitter, '$close' if !scope.currentStep and !options.skipClose

  emitter.unlistenPrevious = EventBus.$on 'previousStep', changeStep(-1, 'Back', options, emitter)
  emitter.unlistenNext     = EventBus.$on 'nextStep',     changeStep(1, 'Complete', options, emitter)
  emitter.unlistenSkip     = EventBus.$on 'skipStep',     changeStep(2, 'Skipped', options, emitter)
