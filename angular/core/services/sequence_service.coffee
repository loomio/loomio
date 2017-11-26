angular.module('loomioApp').factory 'SequenceService', ->
  new class SequenceService
    applySequence: (scope, options = {}) ->

      changeStep = (incr, name) ->
        (args...) ->
          scope.isDisabled = false unless options.keepDisabled
          # perform a callback if its specified
          (options["#{scope.currentStep}#{name}"] or ->)(args...)
          scope.currentStep = scope.steps[scope.currentStepIndex() + incr]
          # don't bubble the event
          args[0].stopPropagation() if typeof (args[0] or {}).stopPropagation is 'function'
          # emit a close event if we've run out of steps
          emitter.$emit '$close' if !scope.currentStep and !options.skipClose

      scope.steps = if typeof options.steps is 'function' then options.steps() else options.steps
      scope.currentStep = options.initialStep or _.first(scope.steps)

      scope.currentStepIndex = ->
        _.indexOf scope.steps, scope.currentStep

      scope.progress = ->
        return unless scope.steps.length > 1
        100 * parseFloat(scope.currentStepIndex()) / (scope.steps.length - 1)

      emitter = options.emitter or scope
      emitter.$on 'previousStep', changeStep(-1, 'Back')
      emitter.$on 'nextStep',     changeStep(1, 'Complete')
