angular.module('loomioApp').factory 'FormService', ($rootScope, FlashService, $filter) ->
  new class FormService

    confirmDiscardChanges: (event, record) ->
      if record.isModified() && !confirm($filter('translate')('common.confirm_discard_changes'))
          return event.preventDefault()

    errorTypes =
      400: 'badRequest'
      401: 'unauthorizedRequest'
      403: 'forbiddenRequest'
      404: 'resourceNotFound'
      422: 'unprocessableEntity'
      500: 'internalServerError'

    submit: (scope, model, options = {}) ->
      submitFn = options.submitFn or model.save
      ->
        FlashService.loading()
        scope.isDisabled = true
        model.setErrors()

        submitFn(model).then( (response) ->
          FlashService.dismiss()
          FlashService.success options.flashSuccess, options.flashOptions if options.flashSuccess?
          scope.$close()                                                  if typeof scope.$close is 'function'
          options.successCallback(response)                               if typeof options.successCallback is 'function'
        , (response) ->
          FlashService.dismiss()
          model.setErrors response.data.errors                            if response.status == 422
          $rootScope.$broadcast errorTypes[response.status] or 'unknownError',
            model: model
            response: response
        ).finally ->
          scope.isDisabled = false
