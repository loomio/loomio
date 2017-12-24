AppConfig             = require 'shared/services/app_config.coffee'
ImplementationService = require 'shared/services/implementation_service.coffee'

module.exports = class FlashService

  ImplementationService.requireMethod(@, 'broadcast', 'setBroadcastMethod')

  createFlashLevel = (level, duration) =>
    (translateKey, translateValues, actionKey, actionFn) =>
      @broadcast 'flashMessage',
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
