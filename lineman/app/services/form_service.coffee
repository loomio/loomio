angular.module('loomioApp').factory 'FormService', ($rootScope, FlashService) ->
  new class FormService

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
        submitFn(model).then (response) ->
          scope.isDisabled = false
          FlashService.success options.flashSuccess, options.flashOptions if options.flashSuccess?
          scope.$close()                                                  if typeof scope.$close == 'function'
          options.successCallback(response)                               if typeof options.successCallback == 'function'
        , (response) ->
          scope.isDisabled = false
          FlashService.dismiss()
          model.setErrors response.data.errors if response.status == 422
          $rootScope.$broadcast errorTypes[response.status] or 'unknownError',
            model: model
            response: response
