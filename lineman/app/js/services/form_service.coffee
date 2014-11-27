angular.module('loomioApp').factory 'FormService', (FlashService) ->
  new class FormService

    applyForm: (scope, service, object, modal) ->
      scope.isDisabled = false

      success = (result) ->
        scope.isDisabled = false
        FlashService.success scope.successMessage()
        scope.successCallback(result[object.constructor.plural][0]) if scope.successCallback?

      failure = (errors) ->
        scope.isDisabled = false
        FlashService.failure errors
        scope.failureCallback() if scope.failureCallback?

      scope.successMessage = scope.successMessage or ->
        singular = object.constructor.singular
        if object.isNew()?
          "flash.#{singular}_form.new_#{singular}"
        else
          "flash.#{singular}_form.update_#{singular}"



      scope.submit = ->
        scope.isDisabled = true
        service.save object, success, failure

      if modal?
        scope.successCallback = ->
          modal.dismiss 'success'

        scope.cancel = ($event) ->
          $event.preventDefault()
          modal.close 'dismiss'
