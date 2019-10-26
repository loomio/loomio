<script lang="coffee">
import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'
import { camelCase } from 'lodash'

export default
  props:
    event: Object
    parentId: Number
    position: Number

  data: ->
    minHeight: null

  mounted: ->

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
    idString: -> "d#{@event.depth}p#{@event.position}" if @event
    minHeightStyle: ->
      if !@event && @minHeight
        {'min-height': @minHeight+'px'}

  watch:
    event:
      immediate: true
      handler: ->
        if @event
          @$nextTick =>
            if @$refs.item && @$refs.item.$el && parseInt(@$refs.item.$el.offsetHeight)
              @minHeight = @$refs.item.$el.offsetHeight
</script>

<template lang="pug">
.thread-item-wrapper(ref="wrapper" :style="minHeightStyle" :id="idString")
  //- | {{minHeight}}
  component(ref="item" v-if="event" :is="componentForKind(event.kind)" :event='event')
  //- div.debug(v-else)
  //-   | parentId {{event.parentId}}
  //-   | position {{event.position}}
  //-   | sequence_id {{event.sequenceId}}
</template>

<style lang="scss">
// .thread-item-wrapper:empty
//   margin: 16px
//   height: 128px
//   // background-color: #999
//   border-radius: 16px
//   background-repeat: no-repeat
//   background-image: radial-gradient(circle 16px, white 99%, transparent 0), linear-gradient(white 40px, transparent 0), linear-gradient(#ccc 100%, transparent 0)
//   background-size: 32px 32px, 200px 40px, 100% 100%
//   background-position: 24px 24px,24px 200px, 0 0

  /*
   * Card Skeleton for Loading
   */

  .thread-item-wrapper {

    &:empty {
      min-height: 100px;
      border-radius: 6px;
      background-color: #ddd;
      margin: 16px;
      border-radius: 16px;
    }
  }

</style>
