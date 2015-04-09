angular.module('loomioApp').factory 'FlashService', ($rootScope) ->
  new class FlashService

    createFlashLevel = (level) =>
      (translateKey, translateValues) =>
        $rootScope.$broadcast 'flashMessage',
          message: translateKey,
          level:   level,
          options: translateValues

    success: createFlashLevel 'success'
    info:    createFlashLevel 'info'
    warning: createFlashLevel 'warning'
    error:   createFlashLevel 'error'
