angular.module('loomioApp').factory 'FormService', (FlashService) ->
  new class FormService

    applyForm: (scope, service, object, modal) ->
      scope.isDisabled = false

      success = ->
        scope.isDisabled = false
        FlashService.success scope.successMessage()
        scope.successCallback() if scope.successCallback?

      failure = (errors) ->
        scope.isDisabled = false
        FlashService.failure errors
        scope.failureCallback() if scope.failureCallback?

      scope.successMessage = scope.successMessage or ->
        type = object.constructor.singular
        if object.isNew()?
          "flash.#{type}_form.new_#{type}"
        else
          "flash.#{type}_form.update_#{type}"

      scope.submit = ->
        scope.isDisabled = true
        service.save object, success, failure

      if modal?
        scope.successCallback = ->
          modal.dismiss 'success'

        scope.cancel = ($event) ->
          $event.preventDefault()
          modal.close 'dismiss'
