<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import RecordLoader from '@/shared/services/record_loader'
import EventHeights from '@/shared/services/event_heights'
import { reverse, groupBy, filter, compact, clone, debounce, range, min, max, map, keys, first, last, sortedUniq, sortBy, difference, isEqual, without } from 'lodash'

export default
  props:
    parentEvent: Object
    focalEvent: Object
    fetch: Function
    newestFirst: Boolean
    isReturning: Boolean

  created: ->
    @fetchMissing = debounce ->
      @fetch(@missingItems)
    , 500

    @watchRecords
      key: 'parentEvent'+@parentEvent.id
      collections: ['events']
      query: => @renderSlots()

  data: ->
    eventsBySlot: {}
    visibleSlots: []
    missingItems: []
    focus: null
    slots: []
    padding: parseInt(screen.height/40) || 20

  methods:
    grouped: (slots) ->
      groupBy slots, (slot) -> parseInt(slot * 0.1)

    renderSlots: ->
      return if @parentEvent.childCount == 0

      # we can let the browser garbage collect if eventsBySlot is too big
      # @eventsBySlot = {} if @slots.length > 1000 # no! just set all existing slots to null so page stays in same place.
      # may want to re scroll after this action.

      if @focalEvent
        @focus = @eventOrParent(@focalEvent).position
      else
        @focus = @visibleSlots[parseInt(@visibleSlots.length / 2)] || 1

      firstItem = max([1, @focus - @padding])
      lastItem = min([@focus + @padding, @parentEvent.childCount])

      firstSlot = max([1, firstItem - (@padding * 2)])
      lastSlot = min([@parentEvent.childCount, lastItem + (@padding * 2)])

      presentItems = []

      Records.events.collection.chain().
      find(parentId: @parentEvent.id).
      find(position: {$between: [firstItem, lastItem]}).
      simplesort('position').
      data().forEach (event) =>
        presentItems.push(event.position)
        @eventsBySlot[event.position] = event

      # after items have been added, we should emit "items added"
        # if they're above visibleSlots, then we need to issue a hold on! alert

      range(firstSlot, lastSlot+1).forEach (slot) =>
        @eventsBySlot[slot] = null unless @eventsBySlot.hasOwnProperty(slot)

      @missingItems = sortBy difference(range(firstItem, lastItem+1), presentItems)

      @slots = sortBy map(keys(@eventsBySlot), Number)

    slotVisible: (isVisible, slot) ->
      # idea: if adding a slot which is not continuous with the other slots, remove the other slots?
      slot = parseInt(slot)
      if isVisible
        @visibleSlots = sortedUniq(sortBy(@visibleSlots.concat([slot])))
      else
        @visibleSlots = without(@visibleSlots, slot)

    eventOrParent: (event) ->
      if !@parentEvent or !event.parent() or (event.depth == @parentEvent.depth + 1)
        event
      else
        @eventOrParent(event.parent())

  computed:
    adjustedSlots: ->
      if @newestFirst && @parentEvent.depth == 0
        reverse clone @slots
      else
        @slots

  watch:
    'parentEvent.childCount': (newVal, oldVal) ->
      console.log 'parentEvent.childCount', newVal, oldVal
      if newVal < oldVal
        @eventsBySlot = {}
        @visibleSlots = []
        @missingItems = []
        @slots = []
        @renderSlots()

    focalEvent: -> @renderSlots()

    visibleSlots:
      immediate: true
      handler: (newVal, oldVal) ->
        unless isEqual(newVal, oldVal) or !@parentEvent
          if @parentEvent.depth == 0
            EventBus.$emit 'visibleSlots', newVal
          @renderSlots()

    missingItems: ->
      @fetchMissing() if @visibleSlots.length

    newestFirst: -> @visibleSlots = []

</script>
<template lang="pug">
.thread-renderer.mb-2
  //- div.thread-renderer__stats.caption(v-if="parentEvent.depth == 0")
    //- | depth {{parentEvent.depth}}
    //- | position {{parentEvent.position}}
    | focus {{focus}}
    | padding {{padding}}
    br
    | childCount {{parentEvent.childCount}}
    | isFocusing {{(focalEvent && true) || false}}
    br
    | missingItems
    p.my-0(v-for="slots in grouped(missingItems)") {{slots}}
    br
    | visibleSlots {{visibleSlots}}
    br
    | slots
    p.my-0(v-for="slots in grouped(slots)") {{slots}}
  .thread-item-slot(v-for="slot in adjustedSlots" :key="slot" v-observe-visibility="{callback: (isVisible) => slotVisible(isVisible, slot)}" )
    thread-item-wrapper(:parent-id="parentEvent.id" :event="eventsBySlot[slot]" :position="parseInt(slot)" :focal-event="focalEvent" :is-returning="isReturning")
</template>

<style lang="sass">
.thread-renderer__stats
  z-index: 1000
  right: 0px
  position: fixed
  bottom: 0px
  height: 300px
  width: 256px
  // opacity: 0.9
  border: 1px solid #eee
  background-color: #ccc
  overflow-y: scroll


</style>
