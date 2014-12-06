angular.module('loomioApp').factory 'FormService', (FlashService) ->
  new class FormService

    applyForm: (scope, object, modal) ->
      scope.isDisabled = false

      success = (response) ->
        scope.isDisabled = false
        FlashService.success scope.successMessage
        results = response[object.constructor.plural] or []
        scope.onSuccess(results[0]) if scope.onSuccess?

      failure = (errors) ->
        scope.isDisabled = false
        FlashService.failure errors
        scope.onFailure() if scope.onFailure?

      scope.submit = ->
        scope.isDisabled = true
        object.save success, failure

      if modal?
        scope.onSuccess = ->
          modal.dismiss 'success'

        scope.cancel = ($event) ->
          $event.preventDefault()
          modal.close 'dismiss'
