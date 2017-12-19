angular.module('loomioApp').factory 'FlashService', ($rootScope, AppConfig) ->
  new class FlashService

    createFlashLevel = (level, duration) =>
      (translateKey, translateValues, actionKey, actionFn) =>
        $rootScope.$broadcast 'flashMessage',
          level:     level
          duration:  duration or AppConfig.flashTimeout.short
          message:   translateKey
          options:   translateValues
          action:    actionKey
          actionFn:  actionFn

    success: createFlashLevel 'success'
    info:    createFlashLevel 'info'
    warning: createFlashLevel 'warning'
    error:   createFlashLevel 'error'
    loading: createFlashLevel 'loading', AppConfig.flashTimeout.long
    update:  createFlashLevel 'update', AppConfig.flashTimeout.long
    dismiss: createFlashLevel 'loading', 1
