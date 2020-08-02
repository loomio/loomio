<script lang="coffee">
# import Records from '@/shared/services/records'
# import EventBus from '@/shared/services/event_bus'
import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'
import NewDiscussion from '@/components/thread/item/new_discussion.vue'
import ThreadItem from '@/components/thread/item.vue'
import ThreadStrand from '@/components/thread/strand.vue'
import { camelCase, first, last } from 'lodash-es'

export default
  name: 'thread-strand'
  props:
    loader: Object
    collection:
      type: Array
      required: true

  components:
    NewDiscussion: NewDiscussion
    NewComment: NewComment
    PollCreated: PollCreated
    StanceCreated: StanceCreated
    OutcomeCreated: OutcomeCreated
    ThreadItem: ThreadItem
    ThreadStrand: ThreadStrand

  computed:
    ids: ->
      @collection.map (e) -> e.event.id

    # firstPosition: ->
    #   return 0 unless @collection.length
    #   @collection[0].event.position
    #
    # lastPosition: ->
    #   return 0 unless @collection.length
    #   last(@collection).event.position
    #
    # parentEvent: ->
    #   @collection[0].event.parent()

  methods:
    componentForKind: (kind) ->
      camelCase if ['stance_created', 'new_comment', 'outcome_created', 'poll_created', 'new_discussion'].includes(kind)
        kind
      else
        'thread_item'
</script>

<template lang="pug">
.thread-strand
  //- p(v-if="firstPosition != 1") {{firstPosition - 1}} items before
  .thread-strand-item(v-for="obj in collection" :event='obj.event' :key="obj.event.id")
    component(:is="componentForKind(obj.event.kind)" :event='obj.event')
    thread-strand(:loader="loader" v-if='obj.children' :collection="obj.children")
  //- p(v-if="lastPosition != parentEvent.childCount") {{parentEvent.childCount - lastPosition}} items after
</template>
