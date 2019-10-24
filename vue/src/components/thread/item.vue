<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'

import { submitForm } from '@/shared/helpers/form'
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'
import { includes, camelCase } from 'lodash'
import RangeSet from '@/shared/services/range_set'

export default
  props:
    event: Object

  data: ->
    isDisabled: false
    collapsed: false
    hover: false
    focusStyleClass: null

  mounted: ->
    @$nextTick =>
      return unless @$refs.defaultSlot
      @$refs.defaultSlot.querySelectorAll("img[height]").forEach (node) =>
        ratio = @$refs.defaultSlot.clientWidth / node.getAttribute('width')
        node.style.height = parseInt(ratio * node.getAttribute('height')) + 'px'

      @$refs.defaultSlot.querySelectorAll("a:not([target])").forEach (node) =>
        node.setAttribute('target', '_blank')

  methods:
    viewed: (viewed) -> @event.markAsRead() if viewed
    focusThenFade: ->
      @focusStyleClass = 'thread-item--focused'
      setTimeout =>
        @focusStyleClass = 'thread-item--previously-focused'
      , 1000

  computed:
    discussion: -> @event.discussion()
    iconSize: -> if (@event.depth == 1) then 40 else 32
    isUnread: ->
      (Session.user().id != @event.actorId) && !RangeSet.includesValue(@discussion.readRanges, @event.sequenceId)

    headline: ->
      @$t eventHeadline(@event, true ), # useNesting
        author:   @event.actorName() || @$t('common.anonymous')
        username: @event.actorUsername()
        key:      @event.model().key
        title:    eventTitle(@event)
        polltype: @$t(eventPollType(@event)).toLowerCase()

    link: ->
      LmoUrlService.event @event

  watch:
    '$route.query.p':
      immediate: true
      handler: (newVal) ->
        @focusThenFade() if parseInt(newVal) == @event.position && @event.depth == 1

    '$route.params.sequence_id':
      immediate: true
      handler: (newVal) ->
        @focusThenFade() if parseInt(newVal) == @event.sequenceId

</script>

<template lang="pug">
div
  .thread-item(:class="[{'thread-item--unread': isUnread}, focusStyleClass]" v-observe-visibility="{callback: viewed, once: true}")
    v-layout.lmo-action-dock-wrapper(:id="'sequence-' + event.sequenceId")
      .thread-item__avatar.mr-4.mt-2
        user-avatar(v-if='!event.isForkable() && event.actor()' :user='event.actor()' :size='iconSize')
        v-checkbox.thread-item__is-forking(v-if="event.isForkable()" @change="event.toggleFromFork()" :disabled="event.forkingDisabled()" v-model="event.isForking()")
      v-layout.thread-item__body(column)
        v-layout.my-1.align-center.wrap
          h3.thread-item__title.body-2(:id="'event-' + event.id")
            //- div
              | id: {{event.id}}
              | pos {{event.position}}
              | sid {{event.sequenceId}}
              | depth: {{event.depth}}
              | childCount: {{event.childCount}}
              | eid: {{event.eventableId}}
            slot(name="headline")
              span(v-html='headline')
            mid-dot
            router-link.grey--text.body-2(:to='link')
              time-ago(:date='event.createdAt')
        .default-slot(ref="defaultSlot")
          slot
        slot(name="actions")
        event-children(v-if='event.childCount > 0' :discussion='discussion' :parent-event='event' :key="event.id")
  slot(name="append")
</template>
<style lang="css">

.thread-item__title > .poll-common-stance-choice {
  display: inline-block;
}
.thread-item__title strong {
  font-weight: normal;
}

.thread-item {
  transition: border-color 10s;
  border-left: 2px solid #fff;
  padding-left: 14px;
}

.thread-item .v-card__actions {
    padding-left: 0;
    padding-right: 0;
}

.thread-item--focused {
  background-color: var(--v-accent-lighten5);
}

.thread-item--previously-focused {
  background-color: none;
  transition: background-color 10s;
}

.thread-item--unread {
  /* // padding-left: $cardPaddingSize - 2px; */
  border-left: 2px solid var(--v-accent-base);
}
.thread-item--unread .thread-item--indent {
    /* // padding-left: $cardPaddingSize + 40px; */
    /* // padding-left: 56px; // (42 (indent) - 2 (unread border) + 16 (card padding)) */
}

/* .thread-item--indent {
  padding-left: 64px;
} */

.thread-item__body {
  width: 100%;
  min-width: 0;
}

@media (max-width: $tiny-max-px){
  .thread-item__directive {
    margin-left: -42px;
  }
}

.thread-item__footer {
  /* // @include fontSmall(); */
  color: $grey-on-white;
  clear: both;
}

.thread-item__actions {
  margin-right: 3px;
  display: inline-block;
}

.thread-item__link:hover  {
  text-decoration: underline;
}

.thread-item__link abbr {
  font-weight: normal;
}

.thread-item__action {
  /* // @include lmoBtnLink; */
  /* color: $link-color; */
}

.thread-item__action--view-edits {
  /* // @include lmoBtnLink; */
  /* color: $grey-on-white; */
}

.thread-item__timestamp {
  display: inline-block;
}
</style>
