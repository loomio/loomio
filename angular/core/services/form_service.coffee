angular.module('loomioApp').factory 'FormService', ($rootScope, FlashService, DraftService, AbilityService, AttachmentService, $filter) ->
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
        model.resetDraft() if options.drafts and AbilityService.isLoggedIn()
        if options.flashSuccess?
          options.flashSuccess = options.flashSuccess() if typeof options.flashSuccess is 'function'
          FlashService.success options.flashSuccess, calculateFlashOptions(options.flashOptions)
        scope.$close()                                          if !options.skipClose? and typeof scope.$close is 'function'
        options.successCallback(response)                       if typeof options.successCallback is 'function'
        $rootScope.$broadcast options.successEvent              if options.successEvent

    failure = (scope, model, options) ->
      (response) ->
        FlashService.dismiss()
        model.setErrors response.data.errors                    if _.contains([401,422], response.status)
        $rootScope.$broadcast errorTypes[response.status] or 'unknownError',
          model: model
          response: response

    cleanup = (scope, model, options = {}) ->
      ->
        options.cleanupFn(scope, model) if typeof options.cleanupFn is 'function'
        scope.isDisabled = false

    submit: (scope, model, options = {}) ->
      DraftService.applyDrafting(scope, model) if options.drafts and AbilityService.isLoggedIn()
      submitFn = options.submitFn or model.save
      (prepareArgs) ->
        return if scope.isDisabled
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
            cleanup(scope, model, options)
          )

    calculateFlashOptions = (options) ->
      _.each _.keys(options), (key) ->
        options[key] = options[key]() if typeof options[key] is 'function'
      options
