<script lang="coffee">
# import Records from '@/shared/services/records'
# import EventBus from '@/shared/services/event_bus'
import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'
import NewDiscussion from '@/components/thread/item/new_discussion.vue'
import ThreadItem from '@/components/thread/item/new_discussion.vue'
import { camelCase } from 'lodash-es'

export default
  props:
    loader: Object
    collection: Array

  components:
    NewDiscussion: NewDiscussion
    NewComment: NewComment
    PollCreated: PollCreated
    StanceCreated: StanceCreated
    OutcomeCreated: OutcomeCreated
    # ThreadItem: ThreadItem
    ThreadStrand: -> import('@/components/thread/strand.vue')

  methods:
    componentForKind: (kind) ->
      camelCase if ['stance_created', 'new_comment', 'outcome_created', 'poll_created', 'new_discussion'].includes(kind)
        kind
      else
        'thread_item'
</script>

<template lang="pug">
.thread-strand
  .thread-strand-item(v-for="obj in collection" :event='obj.event' key="obj.event.id")
    | id {{obj.event.id}}
    component(:is="componentForKind(obj.event.kind)" :event='obj.event' key="obj.event.id")
    thread-strand(:loader="loader" v-if='obj.children' :collection="obj.children")
</template>
