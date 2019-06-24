<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
  props:
    event: Object
    eventable: Object

  mounted: ->
    listenForTranslations(@)

  data: ->
    actions:  [
      name: 'react'
      canPerform: => AbilityService.canReactToPoll(@eventable.poll())
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@eventable)
      perform:    => @eventable.translate(Session.user().locale)
    ]
</script>

<template lang="pug">
.outcome-created
  formatted-text.thread-item__body(:model="eventable" column="statement")
  v-card-actions(wrap)
    reaction-display(:model="eventable")
    v-spacer
    action-dock(:model="eventable" :actions="actions")
</template>
