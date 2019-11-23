<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import RecordLoader from '@/shared/services/record_loader'
import EventHeights from '@/shared/services/event_heights'
import { reverse, filter, compact, clone, debounce, range, min, max, map, keys, first, last, sortedUniq, sortBy, difference, isEqual, without } from 'lodash'

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
    firstItem: null
    lastItem: null
    visibleSlots: []
    missingItems: []
    renderedItems: []
    slots: []
    padding: 2

  methods:
    renderSlots: ->
      return if @parentEvent.childCount == 0
      return if @visibleSlots.length == 0 and !@focalEvent

      # we can let the browser garbage collect if eventsBySlot is too big
      # @eventsBySlot = {} if @slots.length > 1000
      # may want to re scroll after this action.

      if @focalEvent
        focalPosition = @eventOrParent(@focalEvent).position

        @firstItem = max([1, focalPosition - @padding])
        @lastItem = min([focalPosition + @padding, @parentEvent.childCount])
        console.log {focalPosition, @padding}
      else
        @firstItem = max(compact [1, first(@visibleSlots) - @padding])
        @lastItem = min([last(@visibleSlots) + @padding, @parentEvent.childCount])

      # fyi
      # first([]) -> undefined
      # min([undefined, 1]) -> 1
      # max([undefined, 1]) -> 1

      firstSlot = max([1, @firstItem - (@padding * 2)])
      lastSlot = min([@parentEvent.childCount, @lastItem + (@padding * 2)])
      console.log {@firstItem, @lastItem, firstSlot, lastSlot}

      presentItems = []

      Records.events.collection.chain().
      find(parentId: @parentEvent.id).
      find(position: {$between: [@firstItem, @lastItem]}).
      simplesort('position').
      data().forEach (event) =>
        presentItems.push(event.position)
        @eventsBySlot[event.position] = event

      range(firstSlot, lastSlot+1).forEach (slot) =>
        @eventsBySlot[slot] = null unless @eventsBySlot.hasOwnProperty(slot)

      @missingItems = sortBy difference(range(@firstItem, @lastItem+1), presentItems)

      @slots = sortBy map(keys(@eventsBySlot), Number)

    slotVisible: (isVisible, slot) ->
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
    focalEvent: (newVal) ->
      @renderSlots()

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
  div(v-if="parentEvent.depth == 0")
    | depth {{parentEvent.depth}}
    | position {{parentEvent.position}}
    | childCount {{parentEvent.childCount}}
    | isFocusing {{(focalEvent && true) || false}}
    | firstItem {{firstItem}}
    | lastItem {{lastItem}}
    | missingItems {{missingItems}}
    | visibleSlots {{visibleSlots}}
    | renderedItems {{renderedItems}}
    | slots {{slots}}
  .thread-item-slot(v-for="slot in adjustedSlots" :key="slot" v-observe-visibility="{callback: (isVisible) => slotVisible(isVisible, slot)}" )
    thread-item-wrapper(:parent-id="parentEvent.id" :event="eventsBySlot[slot]" :position="parseInt(slot)" :focal-event="focalEvent" :is-returning="isReturning")
  div(v-if="parentEvent.depth == 0")
    | depth {{parentEvent.depth}}
    | position {{parentEvent.position}}
    | childCount {{parentEvent.childCount}}
    | isFocusing {{(focalEvent && true) || false}}
    | firstItem {{firstItem}}
    | lastItem {{lastItem}}
    | missingItems {{missingItems}}
    | visibleSlots {{visibleSlots}}
    | renderedItems {{renderedItems}}
    | slots {{slots}}
</template>
