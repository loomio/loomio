import AppConfig from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'

createFlashLevel = (service, level, duration) ->
  (translateKey, translateValues, actionKey, actionFn) ->
    EventBus.$emit("flash_message",
      level:     level
      duration:  duration or AppConfig.flashTimeout.short
      message:   translateKey
      options:   translateValues
      action:    actionKey
      actionFn:  actionFn
    ) if translateKey

export default class FlashService
  @success: createFlashLevel @, 'success'
  @info:    createFlashLevel @, 'info'
  @warning: createFlashLevel @, 'warning'
  @error:   createFlashLevel @, 'error'
  @loading: createFlashLevel @, 'loading', 1
  @update:  createFlashLevel @, 'update', 1
  @dismiss: createFlashLevel @, 'loading', 1
