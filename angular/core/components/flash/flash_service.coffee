angular.module('loomioApp').factory 'FlashService', ($rootScope) ->
  new class FlashService

    SHORT_TIME = 3500
    LONG_TIME = 2147483645

    createFlashLevel = (level, duration) =>
      (translateKey, translateValues, actionKey, actionFn) =>
        $rootScope.$broadcast 'flashMessage',
          level:     level
          duration:  duration or SHORT_TIME
          message:   translateKey
          options:   translateValues
          action:    actionKey
          actionFn:  actionFn

    success: createFlashLevel 'success'
    info:    createFlashLevel 'info'
    warning: createFlashLevel 'warning'
    error:   createFlashLevel 'error'
    loading: createFlashLevel 'loading', LONG_TIME
    update:  createFlashLevel 'update', LONG_TIME
    dismiss: createFlashLevel 'loading', 1
