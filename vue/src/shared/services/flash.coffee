import AppConfig from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'

createFlashLevel = (level, duration) ->
  (translateKey, translateValues, actionKey, actionFn) ->
    EventBus.$emit("flashMessage",
      level:     level
      duration:  duration or 3500
      message:   translateKey
      options:   translateValues
      action:    actionKey
      actionFn:  actionFn
    ) if translateKey

export default class Flash
  @success: createFlashLevel 'success'
  @info:    createFlashLevel 'info'
  @warning: createFlashLevel 'warning'
  @error:   createFlashLevel 'error'

window.Loomio.flash = Flash
