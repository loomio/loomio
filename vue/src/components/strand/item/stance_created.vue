<script lang="coffee">
import Session        from '@/shared/services/session'
import StanceService        from '@/shared/services/stance_service'
import AbilityService from '@/shared/services/ability_service'
import openModal from '@/shared/helpers/open_modal'
import LmoUrlService  from '@/shared/services/lmo_url_service'

export default
  props:
    event: Object
    eventable: Object
    collapsed: Boolean

  computed:
    actor: -> @event.actor()
    actorName: -> @event.actorName()
    poll: -> @eventable.poll()
    showResults: -> @poll.showResults()
    actions: -> StanceService.actions(@eventable)
    componentType:  ->
      if @actor
        'router-link'
      else
        'div'
    link: ->
      LmoUrlService.event @event
</script>

<template lang="pug">

section.strand-item__stance-created.stance-created(id="'comment-'+ eventable.id" :event="event")
  template(v-if="eventable.singleChoice()")
    .d-flex
      component.text--secondary(:is="componentType" :to="actor && urlFor(actor)") {{actorName}}
      space
      poll-common-stance-choice(v-if="showResults" :poll="poll" :stance-choice="eventable.stanceChoice()")
      space
      router-link.text--secondary(:to='link')
        time-ago(:date='event.createdAt')
  .poll-common-stance(v-if="showResults && !collapsed")
    v-layout(v-if="!eventable.singleChoice()" wrap align-center)
      strand-item-headline.text--secondary(:event="event" :eventable="eventable")
      poll-common-stance-choices(:stance="eventable")
    formatted-text.poll-common-stance-created__reason(:model="eventable" column="reason")
    link-previews(:model="eventable")
    attachment-list(:attachments="eventable.attachments")
  action-dock(:model='eventable' :actions='actions' small)
</template>
