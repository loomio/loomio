<script lang="coffee">
import StrandList from '@/components/strand/list.vue'
import NewComment from '@/components/strand/item/new_comment.vue'
import NewDiscussion from '@/components/strand/item/new_discussion.vue'
import DiscussionEdited from '@/components/strand/item/discussion_edited.vue'
import PollCreated from '@/components/strand/item/poll_created.vue'
import StanceCreated from '@/components/strand/item/stance_created.vue'
import OutcomeCreated from '@/components/strand/item/outcome_created.vue'
import StrandLoadMore from '@/components/strand/load_more.vue'
import OtherKind from '@/components/strand/item/other_kind.vue'
import RangeSet from '@/shared/services/range_set'
import EventBus from '@/shared/services/event_bus'
import { camelCase, first, last, some, sortedUniq, sortBy, without } from 'lodash'

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
    DiscussionEdited: DiscussionEdited

  computed:
    parentExists: ->
      @collection[0] && @collection[0].event && @collection[0].event.parent()

    lastPosition: ->
      (@parentExists && @collection[0].event.parent().childCount) || 0

    positions: ->
      @collection.map (e) -> e.event.position

    ranges: ->
      RangeSet.arrayToRanges(@positions)

    siblingCount: ->
      (@collection &&
      @collection.length &&
      @collection[0].event.parent() &&
      @collection[0].event.parent().childCount) || 1

  methods:
    isFocused: (event) ->
      (event.depth == 1 && event.position == @loader.focusAttrs.position) ||
      (event.positionKey == @loader.focusAttrs.positionKey) ||
      (event.sequenceId == @loader.focusAttrs.sequenceId) ||
      (event.eventableType == 'Comment' && event.eventableId == @loader.focusAttrs.commentId)

    isUnread: (event) ->
      if event.kind == "new_discussion"
        @loader.discussion.updatedAt > @loader.discussion.lastReadAt
      else
        @loader.unreadIds.includes(event.sequenceId)

    positionKeyPrefix: (event) ->
      if event.depth < 1
        event.positionKey.split('-').slice(0, event.depth - 1)
      else
        null

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
      camelCase if ['stance_created', 'discussion_edited', 'new_comment', 'outcome_created', 'poll_created', 'new_discussion'].includes(kind)
        kind
      else
        'other_kind'

    classes: (event) ->
      return [] unless event
      ["lmo-action-dock-wrapper", "positionKey-#{event.positionKey}", "sequenceId-#{event.sequenceId}", "position-#{event.position}"]

</script>

<template lang="pug">
.strand-list
  .strand-item(v-for="obj, index in collection" :event='obj.event' :key="obj.event.id" :class="{'strand-item--deep': obj.event.depth > 1}")
    .strand-item__row(v-if="parentExists && obj.event.position != 1 && isFirstInRange(obj.event.position)")
      .strand-item__gutter
        .strand-item__stem-wrapper
          .strand-item__stem.strand-item__stem--broken
      //- | {{loader.loading}} == {{'before'+obj.event.id}}
      strand-load-more(
        :label="{path: 'common.action.count_more', args: {count: countEarlierMissing(obj.event.position)}}"
        @click="loader.loadBefore(obj.event)"
        :loading="loader.loading == 'before'+obj.event.id")

    .strand-item__row(v-if="!loader.collapsed[obj.event.id]")
      .strand-item__gutter(v-if="obj.event.depth > 0")
        .d-flex.justify-center
          v-checkbox.thread-item__is-forking(v-if="loader.discussion.forkedEventIds.length" @change="obj.event.toggleForking()" :disabled="obj.event.forkingDisabled()" v-model="obj.event.isForking()")
          template(v-else)
            user-avatar(:user="obj.event.actor()" :size="(obj.event.depth > 1) ? 28 : 36" no-link)
        .strand-item__stem-wrapper(@click.stop="loader.collapse(obj.event)")
          .strand-item__stem(:class="{'strand-item__stem--unread': isUnread(obj.event), 'strand-item__stem--focused': isFocused(obj.event), 'strand-item__stem--last': obj.event.position == siblingCount}")
      .strand-item__main
        //- div {{[obj.event.sequenceId]}} {{obj.event.positionKey}} {{isFocused(obj.event)}} {{loader.focusAttrs}}
        div(v-observe-visibility="{intersection: {threshold: 0.25}, callback: (isVisible, entry) => loader.setVisible(isVisible, obj.event)}")
          component(:class="classes(obj.event)" :is="componentForKind(obj.event.kind)" :event='obj.event')

        .strand-list__children(v-if="obj.event.childCount")
          strand-list.flex-grow-1(v-if="obj.children.length" :loader="loader" :collection="obj.children")
          .strand-item__row(v-else)
            .strand-item__gutter
              .strand-item__stem-wrapper
                .strand-item__stem.strand-item__stem--broken
            .strand-item__load-more
              //- | {{loader.loading}} == {{'children'+obj.event.id}}
              strand-load-more(
                :label="{path: 'common.action.count_more', args: {count: obj.event.descendantCount}}"
                @click="loader.loadChildren(obj.event)"
                :loading="loader.loading == 'children'+obj.event.id")

    .strand-item__row(v-if="loader.collapsed[obj.event.id]")
      .d-flex.align-center
        .strand-item__circle.mr-2(v-if="loader.collapsed[obj.event.id]" @click.stop="loader.expand(obj.event)")
          v-icon mdi-unfold-more-horizontal
        strand-item-headline.text--secondary(:event="obj.event" :eventable="obj.event.model()" collapsed)

    //- | {{lastPosition}} {{ranges[ranges.length -1][1]}}
    .strand-item__row(
      v-if="lastPosition != 0 && isLastInLastRange(obj.event.position) && obj.event.position != lastPosition"
      v-observe-visibility="{callback: (isVisible, entry) => isVisible && loader.autoLoadAfter(obj.event), once: true}"
      )
      //- | {{loader.loading}} == {{'after'+obj.event.id}}
      strand-load-more(
        :label="{path: 'common.action.count_more', args: {count: countLaterMissing()}}"
        @click="loader.loadAfter(obj.event)"
        :loading="loader.loading == 'after'+obj.event.id")
</template>

<style lang="sass">

.strand-item--deep
  .strand-item__gutter
    width: 28px
    // margin-right: 4px

  .strand-item__stem
    margin-left: 12px
    margin-right: 12px

  .strand-item__circle
    // margin: 4px 0
    // padding: 4px 0
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

.strand-item__stem-wrapper
  width: 36px
  height: 100%
  padding-top: 4px
  padding-bottom: 4px

.strand-item__stem
  width: 0
  height: 100%
  padding: 0 1px
  background-color: #dadada
  margin: 0px 18px

.strand-item__stem--broken
  background-image: linear-gradient(0deg, #dadada 25%, #ffffff 25%, #ffffff 50%, #dadada 50%, #dadada 75%, #ffffff 75%, #ffffff 100%)
  background-size: 16.00px 16.00px
  // background-size: 24.00px 24.00px
  // background-size: 32.00px 32.00px
  background-repeat: repeat-y



.strand-item__stem--unread
  background-color: var(--v-primary-base)!important

.strand-item__stem--focused
  background-color: var(--v-accent-base)!important

// .strand-item__stem--last
//   height: calc(100% - 44px)
//
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
  margin: 4px 0

.strand-item__circle:hover
  background-color: #dadada


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
