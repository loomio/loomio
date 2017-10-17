angular.module('loomioApp').factory 'SequenceService', ->
  new class SequenceService
    applySequence: (scope, steps, options = {}) ->

      hasStep = (incr) ->
        -> scope.steps[scope.currentStepIndex() + incr]?

      changeStep = (incr, name) ->
        (...args) ->
          scope.currentStep = scope.steps[_.indexOf(scope.currentStep) + incr]
          scope.isDisabled  = false unless options.keepDisabled
          # perform a callback if its specified
          (options["#{scope.currentStep}#{name}"] or ->)(...args)

      scope.steps             = steps or []
      scope.currentStep       = options.initialStep or _.first(steps)
      scope.currentStepIndex  = _.indexOf(scope.currentStep, steps)

      scope.hasPreviousStep   = hasStep(-1)
      scope.hasNextStep       = hasStep(1)
      scope.$on 'previousStep', changeStep(-1, 'Back')
      scope.$on 'nextStep',     changeStep(1, 'Complete')

      scope.progress = ->
        parseFloat(scope.currentStepIndex()) / scope.steps.length
