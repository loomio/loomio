<script lang="coffee">
import OutcomeService from '@/shared/services/outcome_service'
import EventService from '@/shared/services/event_service'

import { pick } from 'lodash'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    event: Object
    isReturning: Boolean

  computed:
    eventable: -> @event.model()
    poll: -> @eventable.poll()
    dockActions: ->
      OutcomeService.actions(@eventable, @)
    menuActions: ->
      pick EventService.actions(@event, @), ['pin_event', 'unpin_event', 'notification_history']

</script>

<template lang="pug">
section.outcome-created.strand-item__outcome-created(id="'outcome-'+ eventable.id")
  strand-item-headline(:event="event" :eventable="eventable")
  formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  //- link-previews(:model="poll")
  //- document-list(:model='eventable' skip-fetch)
  //- attachment-list(:attachments="eventable.attachments")
  action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions')
</template>
