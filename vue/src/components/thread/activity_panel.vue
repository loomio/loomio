<script lang="coffee">
import AppConfig                from '@/shared/services/app_config'
import EventBus                 from '@/shared/services/event_bus'
import RecordLoader             from '@/shared/services/record_loader'
import ChronologicalEventWindow from '@/shared/services/chronological_event_window'
import NestedEventWindow        from '@/shared/services/nested_event_window'
import ModalService             from '@/shared/services/modal_service'
import AbilityService           from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import AuthModalMixin from '@/mixins/auth_modal'
import Records from '@/shared/services/records'
import WatchRecords from '@/mixins/watch_records'
import { print } from '@/shared/helpers/window'
import { compact, snakeCase, camelCase, min, max, times, map, without, uniq, throttle, debounce, range, difference, isNumber, isEqual } from 'lodash'
import RangeSet from '@/shared/services/range_set'
import ThreadActivityMixin from '@/mixins/thread_activity'
import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'

export default
  mixins: [ AuthModalMixin, WatchRecords, ThreadActivityMixin]

  components:
    NewComment: NewComment
    PollCreated: PollCreated
    StanceCreated: StanceCreated
    OutcomeCreated: OutcomeCreated
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    discussion: Object

  data: ->
    loadingFirst: true
    loader: null
    per: 20
    eventsBySlot: {}
    visibleSlots: []
    missingPositions: []
    pageSize: 10


  created: -> @init()

  methods:
    init: ->
      @watchRecords
        key: @discussion.id
        collections: ['groups', 'memberships']
        query: (store) =>
          @canAddComment = AbilityService.canAddComment(@discussion)

      @watchRecords
        key: @discussion.id
        collections: ['events']
        query: (store) =>
          @eventsBySlot = {}
          times @discussion.createdEvent().childCount, (i) =>
            @eventsBySlot[i+1] = null

          store.events.collection.chain().
            find(discussionId: @discussion.id).
            find(depth: 1).data().forEach (event) =>
              @eventsBySlot[event.position] = event

          console.log 'eventsBySlot', @eventsBySlot

      @scrollToInitialPosition()

    scrollToInitialPosition: ->
      commentId = parseInt(@$route.params.comment_id)
      sequenceId = parseInt(@$route.params.sequence_id)
      console.log 'intial position'
      if event = @findEvent('commentId', commentId) or @findEvent('sequenceId', sequenceId)
        @$vuetify.goTo "#sequence-#{event.sequenceId || 0}"
      else
        @loader = new RecordLoader
          collection: 'events'
          params:
            discussion_id: @discussion.id
            order: 'sequence_id'
            comment_id: commentId
            from: sequenceId
            # from_unread: if !commentId && !sequenceId then 1 else null
            per: @pageSize
        @loader.fetchRecords().then =>
          if event = @findEvent('commentId', commentId) or @findEvent('sequenceId', sequenceId)
            @$nextTick => @$vuetify.goTo "#sequence-#{event.sequenceId || 0}"

      EventBus.$on 'threadPositionRequest', (position) => @positionRequested(position)

    findEvent: (column, id) ->
      return false unless isNumber(id)
      records = Records
      if id == 0
        @discussion.createdEvent()
      else
        args = switch camelCase(column)
          when 'position'
            discussionId: @discussion.id
            position: id
            depth: 1
          when 'sequenceId'
            discussionId: @discussion.id
            sequenceId: id
          when 'commentId'
            kind: 'new_comment'
            eventableId: id
        Records.events.find(args)[0]

    positionRequested: (id) ->
      @$vuetify.goTo "#position-#{id}"

    slotVisible: (isVisible, entry, slot, event) ->
      slot = parseInt(slot)
      if isVisible
        EventBus.$emit('threadPositionUpdated', slot)
        @visibleSlots = uniq(@visibleSlots.concat([slot])).sort()
        @missingPositions = uniq(@missingPositions.push(slot)) unless event
      else
        @visibleSlots = without @visibleSlots, slot
        @missingPositions = without @missingPositions, slot

    haveAllEventsBetween: (column, min, max) ->
      expectedLength = switch column
        when 'position' then (max - min) + 1
        when 'sequenceId' then console.error('sequenceId not implemented yet')

      length = Records.events.collection.chain().
        find(discussionId: @discussion.id).
        find(depth: 1).
        find(position: {$between: [min, max]}).data().length

      length == expectedLength

  watch:
    '$route.params.key': 'init'
    '$route.params.sequence_id': 'scrollToInitialPosition'
    '$route.params.comment_id': 'scrollToInitialPosition'
    visibleSlots: throttle (newVal, oldVal) ->
      return if isEqual(newVal, oldVal)
      minPosition = min(newVal) || 1
      maxPosition = max(newVal) || 1

      if @missingPositions.length
        minPosition = min(@missingPositions)
        maxPosition = max(@missingPositions)

      if min(newVal) < min(oldVal)
        #scrolled up
        minPosition = minPosition - @pageSize
      else # assume going to scroll down
        maxPosition = maxPosition + parseInt(@pageSize)

      if @missingPositions.length or !@haveAllEventsBetween('position', minPosition, maxPosition)
        @loader.fetchRecords(
          comment_id: null
          from: null
          from_unread: null
          discussion_id: @discussion.id
          order: 'sequence_id'
          from_sequence_id_of_position: minPosition
          until_sequence_id_of_position: maxPosition)
    ,
      500

  computed:
    canStartPoll: ->
      AbilityService.canStartPoll(@discussion)

    slots: ->
      times(@discussion.createdEvent().childCount, (p) -> p + 1)

</script>

<template lang="pug">
.activity-panel
  .activity_panel__slot(v-for="(event, slot) in eventsBySlot" :id="'position-'+slot" :key="slot" v-observe-visibility="(isVisible, entry) => slotVisible(isVisible, entry, slot, event)" )
    v-sheet.ma-4.pa-4(v-if="!event" color="grey lighten-3" height="200")
      | {{slot}} {{event && event.kind}}

    component(v-if="event" :is="componentForKind(event.kind)" :event='event')
  thread-actions-panel(:discussion="discussion")

</template>
<style lang="scss">
@import 'variables';
/* @import 'mixins'; */

.add-comment-panel__sign-in-btn { width: 100% }
.add-comment-panel__join-actions button {
  width: 100%;
}

.activity-panel__load-more-sensor {
  height: 1px;
}

.activity-panel__load-more{
  /* @include fontSmall; */
  display: flex;
  align-items: center;
  color: $grey-on-grey;
  line-height: 30px;
  padding: 0 10px;
  background-color: $background-color;
  margin-bottom: 20px;
  margin-left: $cardPaddingSize;
  margin-right: $cardPaddingSize;
  cursor: pointer;
  i {
    margin-right: 4px;
    font-size: 16px;
  }
}

.activity-panel__last-read-activity {
  visibility: hidden; /* can't display none because scrolling won't work */
  line-height: 0px;
  margin: -10px 0;
}

</style>
