angular.module('loomioApp').factory 'FormService', (FlashService) ->
  new class FormService

    applyForm: (scope, method, object, modal) ->
      scope.isDisabled = false

      success = (response) ->
        scope.isDisabled = false
        FlashService.success scope.successMessage()
        results = response[object.constructor.plural] or []
        scope.successCallback(results[0]) if scope.successCallback?

      failure = (errors) ->
        scope.isDisabled = false
        FlashService.failure errors
        scope.failureCallback() if scope.failureCallback?

      scope.successMessage = scope.successMessage or ->
        singular = object.constructor.singular
        if object.isNew()
          "flash.#{singular}_form.new_#{singular}"
        else
          "flash.#{singular}_form.update_#{singular}"

      scope.submit = ->
        scope.isDisabled = true
        method object, success, failure

      if modal?
        scope.successCallback = ->
          modal.dismiss 'success'

        scope.cancel = ($event) ->
          $event.preventDefault()
          modal.close 'dismiss'
