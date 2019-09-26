<script lang="coffee">
import AppConfig         from '@/shared/services/app_config'
import EventBus          from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'

import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'

import ThreadRenderer from '@/mixins/thread_renderer_mixin'
import { debounce, first, last } from 'lodash'

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
    discussion: Object
    topVisible: Boolean
    bottomVisible: Boolean

  methods:
    fetchMissing: ->
      if @missingSlots.length
        @loader.fetchRecords(
          comment_id: null
          from_unread: null
          discussion_id: @parentEvent.discussionId
          parent_id: @parentEvent.id
          order: 'position'
          from: first(@missingSlots)
          per: (last(@missingSlots) - first(@missingSlots))+1)

</script>

<template lang="pug">
.event-children
  thread-item-slot(v-for="slot in slots" :key="slot" :event="eventsBySlot[slot]" :position="slot" v-observe-visibility="(isVisible, entry) => slotVisible(isVisible, entry, slot, eventsBySlot[slot])" )
</template>
