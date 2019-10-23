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
    minHeight: 160

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
    minHeightStyle: -> {'min-height': @minHeight+'px'}

  watch:
    event: (newVal) ->
      newVal && @$nextTick =>
        if @$refs.item && @$refs.item.$el
          @minHeight = @$refs.item.$el.offsetHeight
          # console.log 'minHeight', @minHeight

</script>

<template lang="pug">
.thread-item-wrapper(ref="wrapper" :style="minHeightStyle")
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
    // min-height: 160px;
    // width: 280px; //demo
    // height: var(--card-height);
    //

    &:empty {
      --card-padding: 24px;
      --card-height: 340px;
      --card-skeleton: linear-gradadient(lightgrey var(--card-height), transparent 0);

      --avatar-size: 32px;
      --avatar-position: var(--card-padding) var(--card-padding);
      --avatar-skeleton: radial-gradient(circle 16px at center, white 99%, transparent 0 );

      --title-height: 32px;
      --title-width: 200px;
      --title-position: var(--card-padding) 180px;
      --title-skeleton: linear-gradient(white var(--title-height), transparent 0);

      --desc-line-height: 16px;
      --desc-line-skeleton: linear-gradient(white var(--desc-line-height), transparent 0);
      --desc-line-1-width:230px;
      --desc-line-1-position: var(--card-padding) 242px;
      --desc-line-2-width:180px;
      --desc-line-2-position: var(--card-padding) 265px;

      --footer-height: 40px;
      --footer-position: 0 calc(var(--card-height) - var(--footer-height));
      --footer-skeleton: linear-gradient(white var(--footer-height), transparent 0);

      --blur-width: 200px;
      --blur-size: var(--blur-width) calc(var(--card-height) - var(--footer-height));

      min-height: 192px;
      border-radius: 6px;
      background-color: #ccc;
      margin: 16px;
      border-radius: 16px;

      background-image:
        linear-gradient(
          90deg,
          rgba(lightgrey, 0) 0,
          rgba(lightgrey, .8) 50%,
          rgba(lightgrey, 0) 100%
        ),                          //animation blur
        var(--title-skeleton),      //title
        var(--desc-line-skeleton),  //desc1
        var(--desc-line-skeleton),  //desc2
        var(--avatar-skeleton),     //avatar
        var(--footer-skeleton),     //footer bar
        var(--card-skeleton)        //card
      ;

      background-size:
        var(--blur-size),
        var(--title-width) var(--title-height),
        var(--desc-line-1-width) var(--desc-line-height),
        var(--desc-line-2-width) var(--desc-line-height),
        var(--avatar-size) var(--avatar-size),
        100% var(--footer-height),
        100% 100%
      ;

      background-position:
        -150% 0,                      //animation
        var(--title-position),        //title
        var(--desc-line-1-position),  //desc1
        var(--desc-line-2-position),  //desc2
        var(--avatar-position),       //avatar
        var(--footer-position),       //footer bar
        0 0                           //card
      ;

      background-repeat: no-repeat;
      animation: loading 1.5s infinite;
    }
    @keyframes loading {
      to {
        background-position:
          350% 0,
          var(--title-position),
          var(--desc-line-1-position),
          var(--desc-line-2-position),
          var(--avatar-position),
          var(--footer-position),
          0 0
        ;
      }
  }
  }

</style>
