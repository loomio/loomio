angular.module('loomioApp').factory 'FormService', ($rootScope, FlashService, DraftService, $filter) ->
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

    prepare = (scope, model, options, prepareArgs) ->
      FlashService.loading(options.loadingMessage)
      options.prepareFn(prepareArgs) if typeof options.prepareFn is 'function'
      scope.isDisabled = true
      model.setErrors()

    success = (scope, model, options) ->
      (response) ->
        FlashService.dismiss()
        model.resetDraft() if options.allowDrafts
        if options.flashSuccess?
          options.flashSuccess = options.flashSuccess() if typeof options.flashSuccess is 'function'
          FlashService.success options.flashSuccess, calculateFlashOptions(options.flashOptions)
        scope.$close()                                          if typeof scope.$close is 'function'
        options.successCallback(response)                       if typeof options.successCallback is 'function'

    failure = (scope, model, options) ->
      (response) ->
        FlashService.dismiss()
        model.setErrors response.data.errors                            if response.status == 422
        $rootScope.$broadcast errorTypes[response.status] or 'unknownError',
          model: model
          response: response

    cleanup = (scope) ->
      ->
        scope.isDisabled = false

    submit: (scope, model, options = {}) ->
      DraftService.applyDrafting(scope, model) if options.allowDrafts
      submitFn = options.submitFn or model.save
      (prepareArgs) ->
        prepare(scope, model, options, prepareArgs)
        submitFn(model).then(
          success(scope, model, options),
          failure(scope, model, options),
        ).finally(
          cleanup(scope)
        )

    upload: (scope, model, options = {}) ->
      submitFn = options.submitFn
      (files) ->
        if _.any files
          prepare(scope, model, options)
          submitFn(files[0], options.uploadKind).then(
            success(scope, model, options),
            failure(scope, model, options)
          ).finally(
            cleanup(scope)
          )

    calculateFlashOptions = (options) ->
      _.each _.keys(options), (key) ->
        options[key] = options[key]() if typeof options[key] is 'function'
      options
