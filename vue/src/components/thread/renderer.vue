<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import RecordLoader from '@/shared/services/record_loader'
import EventHeights from '@/shared/services/event_heights'
import { reverse, compact, debounce, range, min, max, first, last, sortedUniq, sortBy, difference, isEqual, without } from 'lodash'

export default
  props:
    parentEvent: Object
    focalEvent: Object
    fetch: Function
    newestFirst: Boolean

  created: ->
    @fetchMissing = debounce ->
      @fetch(@missingSlots)
    , 500

    @watchRecords
      key: 'parentEvent'+@parentEvent.id
      collections: ['events']
      query: => @renderSlots()

  data: ->
    eventsBySlot: {}
    visibleSlots: []
    missingSlots: []
    slots: []
    padding: 20
    firstSlot: null
    lastSlot: null

  methods:
    renderSlots: ->
      return if @parentEvent.childCount == 0
      # firstSlot cannot be less than 1
      # firstSlot should not increase
      # lastSlot cannot be greater than childCount

      if @focalEvent
        focalPosition = @focalEvent.position

        firstRendered = max([1, focalPosition - @padding])
        lastRendered = min([focalPosition + @padding, @parentEvent.childCount])
      else
        firstRendered = max([1, first(@visibleSlots) - @padding])
        lastRendered = min([last(@visibleSlots) + @padding, @parentEvent.childCount])

      @firstSlot = max([1, min(compact([@firstSlot, (firstRendered - (@padding * 2))]))])
      @lastSlot = min([@parentEvent.childCount, (lastRendered + (@padding * 2))])

      eventsBySlot = {}
      presentPositions = []
      expectedPositions = range(firstRendered, lastRendered+1)
      # console.log "rendering slots #{@visibleSlots} for depth #{@parentEvent.depth}, position #{@parentEvent.position}, childcount #{@parentEvent.childCount} - firstRendererd #{firstRendered}, lastRendered #{lastRendered}, firstSlot #{@firstSlot}, lastSlot #{@lastSlot}, focalEvent: #{@focalEvent}"

      for i in [@firstSlot..@lastSlot]
        eventsBySlot[i] = null

      Records.events.collection.chain().
      find(parentId: @parentEvent.id).
      find(position: {$between: [firstRendered, lastRendered]}).
      simplesort('position').
      data().forEach (event) =>
        presentPositions.push(event.position)
        eventsBySlot[event.position] = event

      @eventsBySlot = eventsBySlot
      @missingSlots = difference(expectedPositions, presentPositions)

      if @newestFirst && @parentEvent.depth == 0
        @slots = reverse([@firstSlot..@lastSlot])
      else
        @slots = [@firstSlot..@lastSlot]

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

    missingSlots: ->
      @fetchMissing() if @visibleSlots.length

    newestFirst: -> @visibleSlots = []

</script>
<template lang="pug">
.thread-renderer.mb-2
  //- div
    | depth {{parentEvent.depth}}
    | childCount {{parentEvent.childCount}}
    | position {{parentEvent.position}}
    | slots {{slots}}
    | initialSlots {{initialSlots}}
    | visible {{visibleSlots}}
    | missing {{missingSlots}}
  .thread-item-slot(v-for="slot in slots" :key="slot" v-observe-visibility="{callback: (isVisible) => slotVisible(isVisible, slot)}" )
    thread-item-wrapper(:parent-id="parentEvent.id" :event="eventsBySlot[slot]" :position="parseInt(slot)" :focal-event="focalEvent")
</template>
