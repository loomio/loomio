<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import RecordLoader from '@/shared/services/record_loader'
import EventHeights from '@/shared/services/event_heights'
import { reverse, compact, debounce, range, min, max, first, last, sortedUniq, sortBy, difference, isEqual, without } from 'lodash'

export default
  props:
    parentEvent: Object
    fetch: Function
    initialSlots: Array
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

      firstByVisible = first(@visibleSlots) && first(@visibleSlots) - (@padding * 2)
      lastByVisible = last(@visibleSlots) && last(@visibleSlots) + (@padding * 2)

      firstByInitial = first(@initialSlots) && first(@initialSlots) - (@padding * 2)
      lastByInitial = last(@initialSlots) && last(@initialSlots) + (@padding * 2)

      @firstSlot = max([1, min(compact([@firstSlot, firstByInitial, firstByVisible]))])
      @lastSlot = min([@parentEvent.childCount, max(compact([lastByInitial, lastByVisible]))])

      firstRendered = max([1, first(@visibleSlots) - @padding])
      lastRendered = min([last(@visibleSlots) + @padding, @parentEvent.childCount])
      eventsBySlot = {}
      presentPositions = []
      expectedPositions = range(firstRendered, lastRendered+1)
      # console.log "rendering slots #{@visibleSlots} for depth #{@parentEvent.depth}, position #{@parentEvent.position}, childcount #{@parentEvent.childCount} - firstRendererd #{firstRendered}, lastRendered #{lastRendered}, firstSlot #{@firstSlot}, lastSlot #{@lastSlot}, firstByVisible: #{firstByVisible} lastByVisible: #{lastByVisible} padding: #{@padding}, #{@initialSlots}"

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

  watch:
    visibleSlots:
      immediate: true
      handler: (newVal, oldVal) ->
        unless isEqual(newVal, oldVal)
          if @parentEvent.depth == 0
            # console.log 'visibleSlots changed', newVal
            EventBus.$emit 'visibleSlots', newVal
          @renderSlots()

    missingSlots: (newVal, oldVal) ->
      @fetchMissing() if @visibleSlots.length

    initialSlots: (newVal) ->
      @visibleSlots = newVal

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
    thread-item-wrapper(:parent-id="parentEvent.id" :event="eventsBySlot[slot]" :position="parseInt(slot)")
</template>
