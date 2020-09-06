<script lang="coffee">
import StrandList from '@/components/strand/list.vue'
import NewComment from '@/components/strand/item/new_comment.vue'
import NewDiscussion from '@/components/strand/item/new_discussion.vue'
import PollCreated from '@/components/strand/item/poll_created.vue'
import StanceCreated from '@/components/strand/item/stance_created.vue'
import OutcomeCreated from '@/components/strand/item/outcome_created.vue'
import StrandLoadMore from '@/components/strand/load_more.vue'
import OtherKind from '@/components/strand/item/other_kind.vue'
import RangeSet from '@/shared/services/range_set'
import { camelCase, first, last, some } from 'lodash'

export default
  name: 'strand-list'
  props:
    loader: Object
    collection:
      type: Array
      required: true

  components:
    StrandList: StrandList
    NewDiscussion: NewDiscussion
    NewComment: NewComment
    PollCreated: PollCreated
    StanceCreated: StanceCreated
    OutcomeCreated: OutcomeCreated
    OtherKind: OtherKind
    StrandLoadMore: StrandLoadMore

  computed:
    parentExists: ->
      @collection[0] && @collection[0].event && @collection[0].event.parent()

    lastPosition: ->
      (@parentExists && @collection[0].event.parent().childCount) || 0

    positions: ->
      @collection.map (e) -> e.event.position

    ranges: ->
      RangeSet.arrayToRanges(@positions)

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
    siblingCount: ->
      (@collection &&
      @collection.length &&
      @collection[0].event.parent() &&
      @collection[0].event.parent().childCount) || 1

  methods:
    isUnread: (event) ->
      if event.kind == "new_discussion"
        @loader.discussion.updatedAt > @loader.discussion.lastReadAt
      else
        !@loader.readIds.includes(event.sequenceId)

    loadBefore: (event) ->
      @loader.addRule
        local:
          discussionId: @loader.discussion.id
          depth: event.depth
          positionKey: {$lt: event.positionKey}
        remote:
          discussion_id: @loader.discussion.id
          depth: event.depth
          position_key_lt: event.positionKey
          order_by: 'position_key'
          order_desc: 1

      @loader.addRule
        local:
          discussionId: @loader.discussion.id
          depth: event.depth + 1
          position: {$lt: 3}
          positionKey: {$lt: event.positionKey}
        remote:
          discussion_id: @loader.discussion.id
          depth: event.depth + 1
          position_key_lt: event.positionKey
          position_lt: 3
          order_by: 'position_key'
          order_desc: 1

    positionKeyPrefix: (event) ->
      if event.depth < 1
        event.positionKey.split('-').slice(0, event.depth - 1)
      else
        null

    loadChildren: (event) ->
      @loader.addRule
        local:
          discussionId: @loader.discussion.id
          positionKey: {'$regex': "^#{event.positionKey}"}
        remote:
          discussion_id: @loader.discussion.id
          position_key_sw: event.positionKey
          order_by: 'position_key'

    loadAfter: (event) ->
      @loader.addRule
        local:
          discussionId: @loader.discussion.id
          depth: {$gte: event.depth}
          positionKey: {$gt: event.positionKey}
        remote:
          discussion_id: @loader.discussion.id
          position_key_gt: event.positionKey
          # position_key_prefix: @positionKeyPrefix(event)
          depth_lte: event.depth + 2
          depth_gte: event.depth
          order_by: 'position_key'

    isFirstInRange: (pos) ->
      some(@ranges, (range) -> range[0] == pos)

    countEarlierMissing: (pos) ->
      lastPos = 1
      val = 0
      @ranges.forEach (range) ->
        if range[0] == pos
          val = (pos - lastPos)
        else
          lastPos = range[1]
      val

    countLaterMissing: ->
      @lastPosition - last(@ranges)[1]

    isLastInLastRange: (pos) ->
      last(@ranges)[1] == pos

    componentForKind: (kind) ->
      camelCase if ['stance_created', 'new_comment', 'outcome_created', 'poll_created', 'new_discussion'].includes(kind)
        kind
      else
        'other_kind'

</script>

<template lang="pug">
.strand-list
  .strand-item(v-for="obj, index in collection" :event='obj.event' :key="obj.event.id" :class="{'strand-item--deep': obj.event.depth > 1}")
    .strand-item__row(v-if="parentExists && obj.event.position != 1 && isFirstInRange(obj.event.position)")
      .strand-item__gutter
        .strand-item__circle(@click="loadBefore(obj.event)")
          v-icon mdi-unfold-more-horizontal
      strand-load-more(:label="{path: 'common.action.count_more', args: {count: countEarlierMissing(obj.event.position)}}" @click="loadBefore(obj.event)")

    .strand-item__row
      .strand-item__gutter(v-if="obj.event.depth > 0" @click.stop="loader.collapse(obj.event.id)")
        .strand-item__circle(v-if="loader.collapsed[obj.event.id]" @click.stop="loader.expand(obj.event.id)")
          v-icon mdi-unfold-more-horizontal
        template(v-else)
          user-avatar(:user="obj.event.actor()" :size="(obj.event.depth > 1) ? 28 : 36" no-link)
          v-badge(offset-x="48" offset-y="-24" icon="mdi-pin" v-if="obj.event.pinned" color="accent")
            //- i.mdi.mdi-pin.context-panel__heading-pin()
          .strand-item__stem(:class="{'strand-item__stem--unread': isUnread(obj.event), 'strand-item__stem--last': obj.event.position == siblingCount}")
      .strand-item__main
        //- | {{obj.event.sequenceId}} {{obj.event.positionKey}} {{obj.event.childCount}} {{obj.event.descendantCount}}
        component(:is="componentForKind(obj.event.kind)" :event='obj.event' :collapsed="loader.collapsed[obj.event.id]")

        .strand-list__children(v-if="obj.event.childCount")
          //- .strand-item__gutter(v-if="index+1 != siblingCount" @click="loader.collapse(obj.event.id)")
          //-   .strand-item__branch-container
          //-     .strand-item__branch &nbsp;
          //-   .strand-item__stem(v-if="(index+1 != collection.length) || obj.children")

          //- | obj.children {{obj.children.length}}
          strand-list.flex-grow-1(v-if="obj.children.length && !loader.collapsed[obj.event.id]" :loader="loader" :collection="obj.children")
          .strand-item__load-more(v-else)
            //- v-btn.action-button(text block @click="loadChildren(obj.event)" v-t="{path: 'common.action.count_responses', args: {count: obj.event.descendantCount}}")
            strand-load-more(:label="{path: 'common.action.count_responses', args: {count: obj.event.descendantCount}}" @click="loadChildren(obj.event)")

    .strand-item__row(v-if="lastPosition != 0 && isLastInLastRange(obj.event.position) && obj.event.position != lastPosition")
      .strand-item__gutter
        .strand-item__circle(@click="loadAfter(obj.event)")
          v-icon mdi-unfold-more-horizontal
      .strand-item__load-more
        //- | {{obj.event.parent().parentOrSelf().childCount}}
        //- | {{obj.event.positionKey}}
        strand-load-more(:label="{path: 'common.action.count_more', args:{count: countLaterMissing()}}" @click="loadAfter(obj.event)")
        //- | {{lastPosition}} {{ranges}}
</template>

<style lang="sass">

.strand-list
  margin-bottom: 16px

.strand-item--deep
  .strand-item__gutter
    width: 28px
    // margin-right: 4px

  .strand-item__stem
    margin: 0 12px

  .strand-item__circle
    width: 28px
    height: 28px

  .strand-item__load-more
    min-height: 28px

  // not working
  .strand-item__branch-container
    .strand-item__branch
      top: -17px!important
      right: -2px
      // height: 36px
      // width: 36px

.strand-item__row
  display: flex

.strand-item__gutter
  display: flex
  flex-direction: column
  width: 36px
  margin-right: 8px

.strand-item__gutter:hover
  .strand-item__stem
    background-color: #999

.strand-item__main
  flex-grow: 1
  padding-bottom: 8px

.strand-item__stem
  width: 0
  height: 100%
  padding: 0 1px
  background-color: #dadada
  margin: 0 18px

.strand-item__stem--unread
  background-color: var(--v-primary-base)!important

.strand-item__stem--last
  height: calc(100% - 44px)

// .strand-item__stem-stop
//   position: relative
//   left: -16px
//   width: 24px
//   height: 2px
//   background-color: #ddd
//   margin: 0 24px


.strand-item__circle
  display: flex
  align-items: center
  justify-content: center
  width: 36px
  height: 36px
  border: 1px solid #dadada
  border-radius: 100%

.strand-item__circle:hover
  background-color: #dadada

.strand-item__load-more
  display: flex
  align-items: center
  min-height: 36px
  width: 100%
  justify-content: center
  // background: linear-gradient(180deg, rgba(0,0,0,0) calc(50% - 1px), rgba(192,192,192,1) calc(50%), rgba(0,0,0,0) calc(50% + 1px) )

.strand-item__stem:hover
  background-color: #dadada

.strand-item__branch-container
  position: absolute
  overflow: hidden
  margin-right: 4px

.strand-item__branch
  position: relative
  float: left
  top: -13px
  border: 2px solid #dadada
  right: -2px
  height: 28px
  border-radius: 64px
  width: 35px
  margin-left: calc(50% - 1px)
  border-style: solid

</style>
