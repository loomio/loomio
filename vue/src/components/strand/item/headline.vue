<script lang="coffee">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import Records from '@/shared/services/records'

export default
  props:
    event: Object
    eventable: Object
    collapsed: Boolean
    dateTime: Object

  computed:
    datetime: -> @dateTime || @eventable.castAt || @eventable.createdAt
    headline: ->
      actor = @event.actor()
      if @event.kind == 'new_comment' && @collapsed && @event.descendantCount > 0
        @$t('reactions_display.name_and_count_more', {name: actor.nameWithTitle(@eventable.group()), count: @event.descendantCount})
      else
        @$t eventHeadline(@event, true ), # useNesting
          author:   actor.nameWithTitle(@eventable.group())
          username: actor.username
          key:      @event.model().key
          title:    eventTitle(@event)
          polltype: @$t(eventPollType(@event)).toLowerCase()

    link: ->
      LmoUrlService.event @event

</script>

<template lang="pug">
h3.strand-item__headline.thread-item__title.text-body-2.pb-1(tabindex="-1")
  div.d-flex.align-center
    //- v-icon(v-if="event.pinned") mdi-pin
    slot(name="headline")
      span.strand-item__headline.text--secondary(v-html='headline')
    mid-dot
    router-link.text--secondary.text-body-2(:to='link')
      time-ago(:date='datetime')
    mid-dot(v-if="event.pinned")
    v-icon(v-if="event.pinned") mdi-pin-outline

</template>
<style lang="sass">
.strand-item__headline
  strong
    font-weight: 400
  .actor-link
    color: inherit
.text--secondary
  .actor-link
    color: inherit

</style>
