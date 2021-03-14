import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service'

export default
  beforeRouteLeave: (to, from, next) ->
    if RescueUnsavedEditsService.okToLeave()
      next()
    else
      console.log 'not ok'
      next(false)

  beforeRouteEnter: (to, from, next) ->
    RescueUnsavedEditsService.clear()
    next()
