AppConfig = require 'shared/services/app_config.coffee'

module.exports = new class FlashService

  setBroadcastMethod: (broadcast) ->
    @broadcast = broadcast

  broadcast: (args = {}) ->
    console.error "NotImplementedError: No broadcast method passed to FlashService",
                  "Please call 'FlashService.setBroadcastMethod(fn) to set one'"

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
