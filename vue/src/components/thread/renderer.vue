<script lang="coffee">
import { reverse, throttle, debounce, map, range, min, max, times, first, last, clone, cloneDeep, sortedUniq, sortBy, difference, isNumber, isEqual, uniq, without, pull } from 'lodash'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import RecordLoader from '@/shared/services/record_loader'

export default
  props:
    discussion: Object
    parentEvent: Object
    fetch: Function
    viewportIsBelow: Boolean

  created: ->
    console.log "created renderer: parent depth #{@parentEvent.depth}"
    @loader = new RecordLoader
      collection: 'events'
      params:
        per: @padding * 2

    @watchRecords
      key: 'parentEvent'+@parentEvent.id
      collections: ['events']
      query: @renderSlots

    EventBus.$on 'focusedEvent', (event) =>
      @focusedEvent = event          if event.parentId == @parentEvent.id
      @focusedEvent = event.parent() if event.parent() && event.parent().parentId == @parentEvent.id
      @renderSlots()

    @renderSlots()

  data: ->
    loader: null
    eventsBySlot: {}
    visibleSlots: []
    recentSlots: []
    missingSlots: []
    slots: []
    padding: 10
    focusedEvent: null

  methods:

    renderSlots: ->
      return unless @parentEvent.childCount

      if @startAtBeginning
        defaultFirst = 0
        defaultLast = 0
      else
        defaultFirst = @parentEvent.childCount
        defaultLast = @parentEvent.childCount

      firstRendered = max([1, (first(@visibleSlots) || defaultFirst) - @padding])
      lastRendered = min([(last(@visibleSlots) || defaultLast) + @padding, @parentEvent.childCount])

      firstSlot = max([1, firstRendered - @padding])
      lastSlot = min([lastRendered + @padding, @parentEvent.childCount])

      console.log "rendering slots: parent depth #{@parentEvent.depth} startAtBeginning #{@startAtBeginning} firstrendered #{firstRendered} firstSlot #{firstSlot} lastRendered #{lastRendered} lastSlot #{lastSlot} visible #{@visibleSlots}"
      @eventsBySlot = {}
      for i in [firstSlot..lastSlot]
        @eventsBySlot[i] = null

      presentPositions = []
      Records.events.collection.chain().
      find(parentId: @parentEvent.id).
      find(position: {$between: [firstRendered, lastRendered]}).
      simplesort('position').
      data().forEach (event) =>
        presentPositions.push(event.position)
        @eventsBySlot[event.position] = event

      expectedPositions = range(firstRendered, lastRendered+1)
      @missingSlots = difference(expectedPositions, presentPositions)
      console.log "expectedPositions: #{expectedPositions}"
      @eventsBySlot[@focusedEvent.position] = @focusedEvent if @focusedEvent
      @slots = [firstSlot..lastSlot]
      if @discussion.newestFirst && @parentEvent.depth == 0
        @slots = reverse([firstSlot..lastSlot])

    slotVisible: (isVisible, entry, slot, event) ->
      slot = parseInt(slot)
      slotsBefore = clone(@visibleSlots)
      console.log "slotsBefore #{slotsBefore} visibleSlots: #{@visibleSlots}"

      if isVisible
        @visibleSlots = sortBy uniq(@visibleSlots.concat([slot]))
        console.log "depth: #{@parentEvent.depth } with slot: #{slot}. visible: #{@visibleSlots}"
        @renderSlots unless !isEqual(slotsBefore, @visibleSlots)
      else
        pull(@visibleSlots, slot)
        console.log "depth: #{@parentEvent.depth } without slot: #{slot}. visible: #{@visibleSlots}"


    fetchMissing: debounce (slots) ->
      @fetch(slots)
    , 250

  watch:
    missingSlots: (newVal, oldVal) ->
      console.log "parent depth #{@parentEvent.depth} slot #{@parentEvent.position} visible #{@visibleSlots}  missing #{newVal} "
      @fetchMissing(newVal) unless  isEqual(newVal, oldVal)
  computed:
    startAtBeginning: ->
      if @parentEvent.depth == 0
        if @viewportIsBelow
          @discussion.newestFirst
        else
          !@discussion.newestFirst
      else
        true


</script>
<template lang="pug">
.thread-renderer
  thread-item-slot(v-for="slot in slots" :id="'position-'+slot" :key="slot" :event="eventsBySlot[slot]" :position="parseInt(slot)" v-observe-visibility="{callback: (isVisible, entry) => slotVisible(isVisible, entry, slot, eventsBySlot[slot]), throttle: 500, intersection: {threshold: 0.5, rootMargin: '40px'}}" )
  | depth {{parentEvent.depth}}
  | position {{parentEvent.position}}
  | visible {{visibleSlots}}
  | missing {{missingSlots}}
  | viewportIsBelow {{viewportIsBelow}}
</template>
