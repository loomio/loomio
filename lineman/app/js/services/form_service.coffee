angular.module('loomioApp').factory 'FormService', (FlashService) ->
  new class FormService

    applyForm: (scope, service, object) ->
      scope.isDisabled = false

      success = ->
        scope.isDisabled = false
        FlashService.success scope.successMessage() if scope.successMessage?
        scope.successCallback() if scope.successCallback?

      failure = (errors) ->
        scope.isDisabled = false
        FlashService.failure errors
        scope.failureCallback() if scope.failureCallback?

      scope.submit = ->
        scope.isDisabled = true
        service.save object, success, failure
