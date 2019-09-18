<script lang="coffee">
import AppConfig         from '@/shared/services/app_config'
import EventBus          from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'
import RecordLoader from '@/shared/services/record_loader'

import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'

import ThreadRenderer from '@/mixins/thread_renderer_mixin'
import { debounce } from 'lodash'

export default
  mixins: [ThreadRenderer]

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

      @updateRendered(1, 1)

    fetchMissing: debounce ->
      # return false
      if !@haveAllEventsBetween('position', @minRendered, @maxRendered)
        # console.log 'fetching children for ', @parentEvent.id, @minRendered, @maxRendered
        @loader.fetchRecords(
          comment_id: null
          from_unread: null
          discussion_id: @parentEvent.discussionId
          parent_id: @parentEvent.id
          order: 'position'
          from: @minRendered
          per: (@maxRendered - @minRendered)+1)
    , 100

</script>

<template lang="pug">
.event-children
  thread-item-slot(v-for="(event, slot) in eventsBySlot" :key="slot" :event="event" :position="slot" v-observe-visibility="(isVisible, entry) => slotVisible(isVisible, entry, slot, event)" )
</template>
