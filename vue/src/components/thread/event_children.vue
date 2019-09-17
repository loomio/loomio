<script lang="coffee">
import AppConfig         from '@/shared/services/app_config'
import EventBus          from '@/shared/services/event_bus'
import NestedEventWindow from '@/shared/services/nested_event_window'
import WatchRecords from '@/mixins/watch_records'
import RecordLoader from '@/shared/services/record_loader'

import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'

import ThreadActivityMixin from '@/mixins/thread_activity'
import Records from '@/shared/services/records'
import { debounce, min, max, times, difference, isNumber, isEqual, uniq, without } from 'lodash'

export default
  mixins: [WatchRecords, ThreadActivityMixin]

  components:
    NewComment: NewComment
    PollCreated: PollCreated
    StanceCreated: StanceCreated
    OutcomeCreated: OutcomeCreated
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    parentEvent: Object

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
        key: 'parentEvent'+@parentEvent.id
        collections: ['events']
        query: @renderSlots

    renderSlots: ->
      return unless @parentEvent

      @eventsBySlot = {}
      times @parentEvent.childCount, (i) =>
        @eventsBySlot[i+1] = null

      Records.events.collection.chain().
        find(discussionId: @parentEvent.discussionId).
        find(parentId: @parentEvent.id).
        find(position: {$gte: @minRendered}).
        find(position: {$lte: @maxRendered}).data().forEach (event) =>
          @eventsBySlot[event.position] = event

    slotVisible: (isVisible, entry, slot, event) ->
      slot = parseInt(slot)
      if isVisible
        @visibleSlots = uniq(@visibleSlots.concat([slot])).sort()
      else
        @visibleSlots = without @visibleSlots, slot

    haveAllEventsBetween: (column, min, max) ->
      expectedLength = (max - min) + 1

      length = Records.events.collection.chain().
        find(discussionId: @parentEvent.discussionId).
        find(depth: 2).
        find(position: {$between: [min, max]}).data().length

      # console.log "haveAllEventsBetween", length == expectedLength, min, max
      length == expectedLength

    fetchMissing: debounce ->
      if !@haveAllEventsBetween('position', @minRendered, @maxRendered)
        # console.log 'fetching', @minRendered, @maxRendered
        @loader.fetchRecords(
          comment_id: null
          from_unread: null
          discussion_id: @parentEvent.discussionId
          parent_id: @parentEvent.id
          order: 'position'
          from: @minRendered
          per: (@maxRendered - @minRendered))
    ,
      250

  watch:
    visibleSlots: (newVal, oldVal) ->
      return if isEqual(newVal, oldVal)
      minVisible = min(newVal) || 1
      maxVisible = max(newVal) || 1

      @minRendered = max([1, minVisible - @pageSize])
      @maxRendered = min([maxVisible + @pageSize, @parentEvent.childCount])

      # console.log 'visible', minVisible, maxVisible
      # console.log 'rendered', @minRendered, @maxRendered
      @renderSlots()
      @fetchMissing()


</script>

<template lang="pug">
.event-children
  thread-item-slot(v-for="(event, slot) in eventsBySlot" :key="slot" :event="event" :position="slot" v-observe-visibility="(isVisible, entry) => slotVisible(isVisible, entry, slot, event)" )
</template>
