<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'

import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'
import { includes, camelCase } from 'lodash-es'
import RangeSet from '@/shared/services/range_set'

export default
  props:
    isReturning: Boolean
    event:
      type: Object
      required: true

  data: ->
    isDisabled: false
    collapsed: false
    hover: false
    focusStyleClass: null

  methods:
    viewed: (viewed) -> @event.markAsRead() if viewed
    focusThenFade: ->
      @focusStyleClass = 'thread-item--focused'
      setTimeout =>
        @focusStyleClass = 'thread-item--previously-focused'
      , 5000

  computed:
    indentSize: ->
      switch @event.depth
        when 0 then 0
        when 1 then 0
        when 2 then 12 + 40
        when 3 then 68

    discussion: -> @event.discussion()

    iconSize: -> if (@event.depth == 1) then 40 else 24

    isUnread: ->
      Session.isSignedIn() &&
      Session.user().id != @event.actorId &&
      @isReturning && @discussion &&
      !RangeSet.includesValue(@discussion.readRanges, @event.sequenceId)

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

    '$route.params.comment_id':
      immediate: true
      handler: (newVal) ->
        @focusThenFade() if parseInt(newVal) == @event.eventableId

</script>

<template lang="pug">
div
  .thread-item.px-3.pb-1(:class="[{'thread-item--unread': isUnread}, focusStyleClass]" v-observe-visibility="{callback: viewed, once: true}")
    v-layout.lmo-action-dock-wrapper(:style="{'margin-left': indentSize+'px'}"  :id="'sequence-' + event.sequenceId")
      .thread-item__avatar.mr-3.mt-0
        user-avatar(v-if='!event.isForkable() && event.actor()' :user='event.actor()' :size='iconSize')
        v-checkbox.thread-item__is-forking(v-if="event.isForkable()" @change="event.toggleFromFork()" :disabled="event.forkingDisabled()" v-model="event.isForking()")
      v-layout.thread-item__body(column)
        v-layout.align-center.wrap
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
  slot(name="append")
</template>
<style lang="sass">
.thread-item__title
	& > .poll-common-stance-choice
		display: inline-block
	strong
		font-weight: normal
.thread-item
	transition: background 4s ease-out
	.v-card__actions
		padding-left: 0
		padding-right: 0
.thread-item--focused
	background-color: var(--v-accent-lighten5)
.thread-item--previously-focused
	background-color: none
.thread-item--unread
	background-color: var(--v-primary-lighten5)
.thread-item__body
	width: 100%
	min-width: 0

</style>
