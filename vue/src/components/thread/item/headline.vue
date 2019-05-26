<script lang="coffee">
import { camelCase } from 'lodash'
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import AbilityService from '@/shared/services/ability_service'

export default
  props:
    event: Object
    eventable: Object
    eventWindow: Object
    actions: Array

  methods:
    camelCase: camelCase

  computed:
    link: ->
      LmoUrlService.event @event

    headline: ->
      @$t eventHeadline(@event, @eventWindow.useNesting),
        author:   @event.actorName() || @$t('common.anonymous')
        username: @event.actorUsername()
        key:      @event.model().key
        title:    eventTitle(@event)
        polltype: @$t(eventPollType(@event)).toLowerCase()

</script>
<template lang="pug">
.thread-item-headline
  h3.thread-item__title(:id="'event-' + event.id")
    span(v-html='headline')
    |
    |
    span(aria-hidden='true') ·
    |
    |
    //- router-link.thread-item__link.lmo-pointer(:to='link')
    //-   time-ago.timeago--inline(:date='event.createdAt')
  action-dock(:model="eventable" :actions="actions" v-if="actions.length")
</template>

<style lang="scss">
@import 'variables';
@import 'mixins';

.thread-item__link abbr span {
  font-weight: normal;
  color: $grey-on-white;
}

.thread-item__title {
  /* these styles break with BEM but they keep the translations clean*/
  flex-grow: 1;
  color: $grey-on-white;
  strong, a {
    color: $primary-text-color;
    @include md-body-2;
  }
  strong:nth-child(2) {
    font-weight: normal;
    color: $grey-on-white;
  }
}

.thread-item-headline {
  min-height: 28px;
  display: flex;
  flex-direction: row;
  align-items: center;
  flex-grow: 1;
  justify-content:space-between;
}

</style>
