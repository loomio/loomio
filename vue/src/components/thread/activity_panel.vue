<script lang="coffee">
import Vue from 'vue'
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import ModalService             from '@/shared/services/modal_service'
import AbilityService           from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
import { print } from '@/shared/helpers/window'
import RangeSet from '@/shared/services/range_set'
import ThreadRenderer from '@/mixins/thread_renderer_mixin'

import { compact, snakeCase, camelCase, min, max, map, first, last, without, uniq, throttle, debounce, range, difference, isNumber, isEqual } from 'lodash'

export default
  mixins: [ AuthModalMixin, ThreadRenderer]

  props:
    discussion: Object
    topVisible: Boolean
    bottomVisible: Boolean

  data: ->
    parentEvent: @discussion.createdEvent()
    loader: null

  created: ->
    @watchRecords
      key: @discussion.id
      collections: ['groups', 'memberships']
      query: =>
        @canAddComment = AbilityService.canAddComment(@discussion)

    @scrollToInitialPosition()

  methods:
    scrollToInitialPosition: ->
      waitFor = (selector, fn) ->
        if document.querySelector(selector)
          fn()
        else
          setTimeout ->
            waitFor(selector, fn)
          , 250

      focusOnEvent = (event) =>
        EventBus.$emit('focusedEvent', event)
        waitFor "#sequence-#{event.sequenceId || 0}", =>
          EventBus.$emit('focusedEvent', event)
          @$vuetify.goTo "#sequence-#{event.sequenceId || 0}", offset: 96, duration: 0
          setTimeout =>
            @$vuetify.goTo "#sequence-#{event.sequenceId || 0}", offset: 96, duration: 0
          , 3000

      commentId = parseInt(@$route.params.comment_id)
      sequenceId = parseInt(@$route.params.sequence_id)
      return unless commentId or sequenceId

      if event = @findEvent('commentId', commentId) or @findEvent('sequenceId', sequenceId)
        focusOnEvent(event)
      else
        @loader.fetchRecords(
          discussion_id: @discussion.id
          order: 'sequence_id'
          comment_id: commentId
          from: sequenceId
          # from_unread: if !commentId && !sequenceId then 1 else null
          per: @pageSize
        ).then =>
          if event = @findEvent('commentId', commentId) or @findEvent('sequenceId', sequenceId)
            focusOnEvent(event)

      EventBus.$on 'threadPositionRequest', (position) => @positionRequested(position)

    findEvent: (column, id) ->
      return false unless isNumber(id)
      records = Records
      if id == 0
        @discussion.createdEvent()
      else
        args = switch camelCase(column)
          when 'position'
            discussionId: @discussion.id
            position: id
            depth: 1
          when 'sequenceId'
            discussionId: @discussion.id
            sequenceId: id
          when 'commentId'
            kind: 'new_comment'
            eventableId: id
        Records.events.find(args)[0]

    positionRequested: (id) ->
      @$vuetify.goTo "#position-#{id}", duration: 0

    fetchMissing: debounce ->
      if @missingSlots.length
        @loader.fetchRecords(
          comment_id: null
          from: null
          from_unread: null
          discussion_id: @discussion.id
          order: 'sequence_id'
          from_sequence_id_of_position: first(@missingSlots)
          until_sequence_id_of_position: last(@missingSlots))
    , 500

  watch:
    '$route.params.sequence_id': 'scrollToInitialPosition'
    '$route.params.comment_id': 'scrollToInitialPosition'

  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

</script>

<template lang="pug">
.activity-panel.py-2
  thread-item-slot(v-for="slot in slots" :id="'position-'+slot" :key="slot" :event="eventsBySlot[slot]" :position="parseInt(slot)" v-observe-visibility="(isVisible, entry) => slotVisible(isVisible, entry, slot, eventsBySlot[slot])" )
</template>
