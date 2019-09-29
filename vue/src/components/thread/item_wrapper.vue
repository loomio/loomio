<script lang="coffee">
import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'
import EventHeights from '@/shared/services/event_heights'
import { camelCase } from 'lodash'

export default
  props:
    event: Object
    parentId: Number
    position: Number

  components:
    NewComment: NewComment
    PollCreated: PollCreated
    StanceCreated: StanceCreated
    OutcomeCreated: OutcomeCreated
    ThreadItem: -> import('@/components/thread/item.vue')

  methods:
    componentForKind: (kind) ->
      camelCase if ['stance_created', 'new_comment', 'outcome_created', 'poll_created'].includes(kind)
        kind
      else
        'thread_item'

  computed:
    heightStyle: ->
      if @event
        {}
      else
        {height: (EventHeights[@parentId] && EventHeights[@parentId][@position] || 200)+'px'}

  watch:
    event: ->
      if @event
        @$nextTick =>
          return unless @$refs.item
          EventHeights[@parentId] = {} unless EventHeights[@parentId]
          EventHeights[@parentId][@position] = @$refs.item.$el.offsetHeight

</script>
<template lang="pug">
div(:style="heightStyle")
  component(ref="item" v-if="event" :is="componentForKind(event.kind)" :event='event')
  v-sheet.ma-4.pa-4(v-else  color="grey lighten-3" style="height: 100%")
    v-layout.grey--text.text-center(style="height: 100%" justify-center align-center)
      span(v-t="'common.action.loading'")
      space
      | {{position}}
      space
      | …

</template>
