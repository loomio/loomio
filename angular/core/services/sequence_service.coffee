angular.module('loomioApp').factory 'SequenceService', ->
  new class SequenceService
    applySequence: (scope, steps, options = {}) ->

      changeStep = (incr, name) ->
        (args...) ->
          scope.isDisabled = false unless options.keepDisabled
          # perform a callback if its specified
          (options["#{scope.currentStep}#{name}"] or ->)(args...)
          scope.currentStep = scope.steps[scope.currentStepIndex() + incr]
          # emit a close event if we've run out of steps
          emitter.$emit '$close' if !scope.currentStep

      scope.steps       = steps or []
      scope.currentStep = options.initialStep or _.first(steps)

      scope.currentStepIndex = ->
        _.indexOf scope.steps, scope.currentStep

      scope.progress = ->
        parseFloat(scope.currentStepIndex()) / scope.steps.length

      emitter = options.emitter or scope
      emitter.$on 'previousStep', changeStep(-1, 'Back')
      emitter.$on 'nextStep',     changeStep(1, 'Complete')
