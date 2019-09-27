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
    viewportIsAbove: Boolean

  created: ->
    identifier = 'parentEvent'+@parentEvent.id
    @loader = new RecordLoader
      collection: 'events'
      params:
        per: @padding * 2

    @watchRecords
      key: 'parentEvent'+@parentEvent.id
      collections: ['events']
      query: @renderSlots

    EventBus.$on 'focusedEvent', @focused

    @renderSlots()

  beforeDestroy: ->
    delete @loader
    EventBus.$off 'focusedEvent', @focused


  data: ->
    loader: null
    eventsBySlot: {}
    visibleSlots: []
    recentSlots: []
    missingSlots: []
    slots: []
    padding: 20
    focusedEvent: null

  methods:
    focused: (event) ->
      @focusedEvent = event          if event.parentId == @parentEvent.id
      @focusedEvent = event.parent() if event.parent() && event.parent().parentId == @parentEvent.id

    renderSlots: ->
      defaultFirst = 0
      defaultLast = 0
      if @parentEvent.depth == 0 && (@discussion.newestFirst || @viewportIsBelow)
        defaultFirst = @parentEvent.childCount
        defaultLast = @parentEvent.childCount

      firstRendered = max([1, (first(@visibleSlots) || defaultFirst) - @padding])
      lastRendered = min([(last(@visibleSlots) || defaultLast) + @padding, @parentEvent.childCount])

      firstSlot = max([1, firstRendered - 1])
      lastSlot = min([lastRendered + 1, @parentEvent.childCount])
      # firstSlot = firstRendered
      # lastSlot = lastRendered

      # console.log "rendering slots: parent depth #{@parentEvent.depth} startAtBeginning #{@startAtBeginning} firstrendered #{firstRendered} firstSlot #{firstSlot} lastRendered #{lastRendered} lastSlot #{lastSlot} visible #{@visibleSlots}"
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
      # console.log "expectedPositions: #{expectedPositions}"
      @eventsBySlot[@focusedEvent.position] = @focusedEvent if @focusedEvent
      @slots = [firstSlot..lastSlot]
      if @discussion.newestFirst && @parentEvent.depth == 0
        @slots = reverse([firstSlot..lastSlot])

    fetchMissing: debounce (slots) ->
      @fetch(slots)
    , 250

    slotVisible: (isVisible, entry, slot, event) ->
      slot = parseInt(slot)
      if isVisible
        @visibleSlots = sortedUniq(sortBy(@visibleSlots.concat([slot])))
      else
        @visibleSlots = without(@visibleSlots, slot)

  watch:
    visibleSlots: (newVal, oldVal) ->
      # console.log "visibleSlots #{@visibleSlots}"
      @renderSlots() unless isEqual(newVal, oldVal)

    missingSlots: (newVal, oldVal) ->
      @fetch(newVal) unless isEqual(newVal, oldVal)

    'discussion.newestFirst': -> @visibleSlots = []
    # 'viewportIsBelow': (newVal, oldVal) -> @visibleSlots = [] if newVal
    # 'viewportIsAbove': (newVal, oldVal) -> @visibleSlots = [] if newVal


</script>
<template lang="pug">
.thread-renderer
  thread-item-slot(v-for="slot in slots" :id="'position-'+slot" :key="slot" :event="eventsBySlot[slot]" :position="parseInt(slot)" v-observe-visibility="{callback: (isVisible, entry) => slotVisible(isVisible, entry, slot, eventsBySlot[slot]), intersection: {threshold: 0.1, rootMargin: '40px'}}" )
  //- div
    | depth {{parentEvent.depth}}
    | position {{parentEvent.position}}
    | visible {{visibleSlots}}
    | missing {{missingSlots}}
    | viewportIsBelow {{viewportIsBelow}}
</template>
