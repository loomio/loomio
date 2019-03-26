AppConfig             = require 'shared/services/app_config'
ImplementationService = require 'shared/services/implementation_service'

createFlashLevel = (service, level, duration) ->
  (translateKey, translateValues, actionKey, actionFn) ->
    service.broadcast(
      level:     level
      duration:  duration or AppConfig.flashTimeout.short
      message:   translateKey
      options:   translateValues
      action:    actionKey
      actionFn:  actionFn
    ) if translateKey

module.exports = class FlashService
  ImplementationService.requireMethod(@, 'broadcast', 'setBroadcastMethod')

  @success: createFlashLevel @, 'success'
  @info:    createFlashLevel @, 'info'
  @warning: createFlashLevel @, 'warning'
  @error:   createFlashLevel @, 'error'
  @loading: createFlashLevel @, 'loading', AppConfig.flashTimeout.long
  @update:  createFlashLevel @, 'update', AppConfig.flashTimeout.long
  @dismiss: createFlashLevel @, 'loading', 1
