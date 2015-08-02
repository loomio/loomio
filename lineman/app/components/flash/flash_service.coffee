angular.module('loomioApp').factory 'FlashService', ($rootScope) ->
  new class FlashService

    SHORT_TIME = 2500
    LONG_TIME = 2147483645

    createFlashLevel = (level, duration) =>
      (translateKey, translateValues) =>
        $rootScope.$broadcast 'flashMessage',
          level:    level,
          duration: duration or SHORT_TIME,
          message:  translateKey,
          options:  translateValues

    success: createFlashLevel 'success'
    info:    createFlashLevel 'info'
    warning: createFlashLevel 'warning'
    error:   createFlashLevel 'error'
    loading: createFlashLevel 'loading', LONG_TIME
    dismiss: createFlashLevel 'loading', 1
