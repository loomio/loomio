<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import openModal from '@/shared/helpers/open_modal'
import StanceService from '@/shared/services/stance_service'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    event: Object
    isReturning: Boolean

  computed:
    eventable: -> @event.model()
    poll: -> @eventable.poll()
    showResults: -> @eventable.poll().showResults()
    actions: -> StanceService.actions(@eventable)

    componentType:  ->
      if @event.actor()
        'router-link'
      else
        'div'
</script>

<template lang="pug">
thread-item.stance-created(:event="event" :is-returning="isReturning")
  template(v-slot:actions)
    action-dock(:model="eventable" :actions="actions")
  template(v-if="eventable.singleChoice()" v-slot:headline)
    component(:is="componentType" :to="event.actor() && urlFor(event.actor())") {{event.actorName()}}
    space
    poll-common-stance-choice(v-if="showResults" :poll="poll" :stance-choice="eventable.stanceChoice()")
  .poll-common-stance(v-if="showResults")
    poll-common-stance-choices(:stance="eventable")
    formatted-text.poll-common-stance-created__reason(:model="eventable" column="reason")
    link-previews(:model="eventable")
    attachment-list(:attachments="eventable.attachments")
</template>
