<script lang="coffee">
import AppConfig         from '@/shared/services/app_config'
import EventBus          from '@/shared/services/event_bus'
import WatchRecords from '@/mixins/watch_records'
import RecordLoader from '@/shared/services/record_loader'

import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'

import { debounce, first, last } from 'lodash'

export default
  components:
    NewComment: NewComment
    PollCreated: PollCreated
    StanceCreated: StanceCreated
    OutcomeCreated: OutcomeCreated
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    parentEvent: Object
    discussion: Object

  created: ->
    @loader = new RecordLoader
      collection: 'events'

  methods:
    fetch: (slots) ->
      return unless slots.length
      @loader.fetchRecords(
        comment_id: null
        from_unread: null
        discussion_id: @parentEvent.discussionId
        parent_id: @parentEvent.id
        order: 'position'
        from: first(slots)
        per: (last(slots) - first(slots))+1)

</script>

<template lang="pug">
.event-children
  thread-renderer(:discussion="discussion" :parent-event="parentEvent" :fetch="fetch")
</template>
