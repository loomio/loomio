<script lang="coffee">
# import Records from '@/shared/services/records'
# import EventBus from '@/shared/services/event_bus'
import StrandList from '@/components/strand/list.vue'
import NewComment from '@/components/strand/item/new_comment.vue'
import NewDiscussion from '@/components/strand/item/new_discussion.vue'
import PollCreated from '@/components/strand/item/poll_created.vue'
import StanceCreated from '@/components/strand/item/stance_created.vue'
import OutcomeCreated from '@/components/strand/item/outcome_created.vue'
import OtherKind from '@/components/strand/item/other_kind.vue'
import RangeSet from '@/shared/services/range_set'
import { camelCase, first, last, some } from 'lodash-es'

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

  methods:
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
        'strand_item'
</script>

<template lang="pug">
.strand-list
  //- | ranges: {{ranges}}
  .strand-item(v-for="obj, index in collection" :event='obj.event' :key="obj.event.id")

    p(v-if="parentExists && obj.event.position != 1 && isFirstInRange(obj.event.position)") {{countEarlierMissing(obj.event.position)}} earlier items missing
    .d-flex
      .strand-item__gutter.d-flex.flex-column
        //- | {{obj.event.position}}
        user-avatar(:user="obj.event.actor()" :size="48")
        .strand-item__stem(v-if="(index+1 != collection.length) || obj.children")
      .thread-strand__body.flex-grow-1
        //- | positionKey {{obj.event.positionKey}}
        component(:is="componentForKind(obj.event.kind)" :event='obj.event')
        p(v-if="obj.event.childCount && !obj.children") {{obj.event.childCount}} replies

    .strand-list__children(v-if="obj.children && obj.children.length")
      .d-flex
        .strand-item__gutter.d-flex.flex-column(v-if="index+1 != collection.length")
          .strand-item__branch-container
            .strand-item__branch &nbsp;
          .strand-item__stem(v-if="(index+1 != collection.length) || obj.children")
        strand-list.flex-grow-1(:loader="loader" :collection="obj.children")

    p(v-if="lastPosition != 0 && isLastInLastRange(obj.event.position) && obj.event.position != lastPosition") {{countLaterMissing()}} further items missing

    //- collection 0 .. no render children
    //- collection 1, children 0. no line
    //- collection 1, children > 0, line, no indent
    //- collection > 1, line, indent children
    //- p(v-if="firstPosition != 1") {{firstPosition - 1}} items before

  //- .thread-strand__load-children(v-if="collection.length == 0 && obj.event.childCount > 0")
  //-   | show more
  //-   there are children to load
  //- p(v-if="lastPosition != parentEvent.childCount") {{parentEvent.childCount - lastPosition}} items after
</template>

<style lang="sass">
.strand-list__indent
  margin-left: 64px

.strand-item__stem
  float: left
  width: 0
  border: 1px solid grey
  height: 100%
  margin: 0 24px

.strand-item__branch-container
  position: absolute
  overflow: hidden
  margin-right: 4px

.strand-item__branch
  position: relative
  float: left
  top: -24px
  border: 2px solid grey
  right: -2px
  height: 48px
  border-radius: 64px
  width: 48px

  // top
  // width: 12px
  margin-left: calc(50% - 1px)
  // border-left-width: 2px
  // border-bottom-width: 2px
  // border-bottom-left-radius: 10px
  border-style: solid

</style>
