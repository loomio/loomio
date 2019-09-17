<script lang="coffee">
import Vue from 'vue'
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import ChronologicalEventWindow from '@/shared/services/chronological_event_window'
import NestedEventWindow        from '@/shared/services/nested_event_window'
import ModalService             from '@/shared/services/modal_service'
import AbilityService           from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
import { print } from '@/shared/helpers/window'
import { compact, snakeCase, camelCase, min, max, times, map, without, uniq, throttle, debounce, range, difference, isNumber, isEqual } from 'lodash'
import RangeSet from '@/shared/services/range_set'

export default
  mixins: [ AuthModalMixin, WatchRecords]

  props:
    discussion: Object

  data: ->
    loader: null
    eventsBySlot: {}
    visibleSlots: []
    minRendered: 0
    maxRendered: 0
    pageSize: 10

  created: -> @init()

  methods:
    init: ->
      @loader = new RecordLoader
        collection: 'events'

      @watchRecords
        key: @discussion.id
        collections: ['groups', 'memberships']
        query: =>
          @canAddComment = AbilityService.canAddComment(@discussion)

      @watchRecords
        key: @discussion.id
        collections: ['events']
        query: @renderSlots

      @scrollToInitialPosition()

    renderSlots: ->
      return unless @discussion.createdEvent()

      @eventsBySlot = {}
      times @discussion.createdEvent().childCount, (i) =>
        @eventsBySlot[i+1] = null

      Records.events.collection.chain().
        find(discussionId: @discussion.id).
        find(position: {$gte: @minRendered}).
        find(position: {$lte: @maxRendered}).
        find(depth: 1).data().forEach (event) =>
          @eventsBySlot[event.position] = event


    scrollToInitialPosition: ->
      waitFor = (selector, fn) ->
        if document.querySelector(selector)
          fn()
        else
          setTimeout ->
            waitFor(selector, fn)
          , 50

      focusOnEvent = (event) =>
        waitFor "#sequence-#{event.sequenceId || 0}", =>
          EventBus.$emit('focusedEvent', event)
          @$vuetify.goTo "#sequence-#{event.sequenceId || 0}", offset: 96

      commentId = parseInt(@$route.params.comment_id)
      sequenceId = parseInt(@$route.params.sequence_id)

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
      @$vuetify.goTo "#position-#{id}"

    slotVisible: (isVisible, entry, slot, event) ->
      slot = parseInt(slot)
      if isVisible
        EventBus.$emit('threadPositionUpdated', slot)
        @visibleSlots = uniq(@visibleSlots.concat([slot])).sort()
      else
        @visibleSlots = without @visibleSlots, slot

    haveAllEventsBetween: (column, min, max) ->
      expectedLength = switch column
        when 'position' then (max - min) + 1
        when 'sequenceId' then console.error('sequenceId not implemented yet')

      length = Records.events.collection.chain().
        find(discussionId: @discussion.id).
        find(depth: 1).
        find(position: {$between: [min, max]}).data().length

      # console.log "haveAllEventsBetween", length == expectedLength, min, max
      length == expectedLength

    fetchMissing: debounce ->
      if !@haveAllEventsBetween('position', @minRendered, @maxRendered)
        # console.log 'fetching', @minRendered, @maxRendered
        @loader.fetchRecords(
          comment_id: null
          from: null
          from_unread: null
          discussion_id: @discussion.id
          order: 'sequence_id'
          from_sequence_id_of_position: @minRendered
          until_sequence_id_of_position: @maxRendered)
    ,
      250


  watch:
    '$route.params.key': 'init'
    '$route.params.sequence_id': 'scrollToInitialPosition'
    '$route.params.comment_id': 'scrollToInitialPosition'
    visibleSlots: (newVal, oldVal) ->
      return if isEqual(newVal, oldVal)
      minVisible = min(newVal) || 1
      maxVisible = max(newVal) || 1

      @minRendered = max([1, minVisible - @pageSize])
      @maxRendered = min([maxVisible + @pageSize, @discussion.createdEvent().childCount])

      # console.log 'visible', minVisible, maxVisible
      # console.log 'rendered', @minRendered, @maxRendered
      @renderSlots()
      @fetchMissing()


  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

    slots: ->
      times(@discussion.createdEvent().childCount, (p) -> p + 1)

</script>

<template lang="pug">
.activity-panel
  thread-item-slot(v-for="(event, slot) in eventsBySlot" :id="'position-'+slot" :key="slot" :event="event" :position="slot" v-observe-visibility="(isVisible, entry) => slotVisible(isVisible, entry, slot, event)" )
  thread-actions-panel(:discussion="discussion")
</template>
