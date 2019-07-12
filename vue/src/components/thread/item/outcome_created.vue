<script lang="coffee">
import OutcomeService from '@/shared/services/outcome_service'
import EventService from '@/shared/services/event_service'

import { listenForTranslations } from '@/shared/helpers/listen'
import { pick } from 'lodash'

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
    poll: -> @eventable.poll()
    dockActions: ->
      OutcomeService.actions(@eventable, @)
    menuActions: ->
      pick EventService.actions(@event, @), ['pin_event', 'unpin_event']

</script>

<template lang="pug">
thread-item.outcome-created(:event="event" :event-window="eventWindow")
  template(v-slot:actions)
    action-dock(:model="eventable" :actions="dockActions")
    action-menu(:model="eventable" :actions="menuActions")
  formatted-text.thread-item__body(:model="eventable" column="statement")
  reaction-display(:model="eventable")
</template>
