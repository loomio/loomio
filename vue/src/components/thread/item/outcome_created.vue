<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')
    
  props:
    event: Object
    eventWindow: Object

  mounted: ->
    listenForTranslations(@)

  computed:
    eventable: -> @event.model()

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
thread-item.outcome-created(:event="event" :event-window="eventWindow")
  formatted-text.thread-item__body(:model="eventable" column="statement")
  v-card-actions(wrap)
    reaction-display(:model="eventable")
    v-spacer
    action-dock(:model="eventable" :actions="actions")
</template>
