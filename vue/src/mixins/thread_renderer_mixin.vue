<script lang="coffee">
import { reverse, throttle, debounce, map, range, min, max, times, first, last, sortedUniq, sortBy, difference, isNumber, isEqual, uniq, without } from 'lodash'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import RecordLoader from '@/shared/services/record_loader'

export default
  created: ->
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
    missingSlots: []
    slots: []
    padding: 20
    focusedEvent: null

  methods:
    startAtBeginning: ->
      if @parentEvent.depth == 1
        @topVisible && !@discussion.newestFirst
      else
        @topVisible

    renderSlots: ->
      @eventsBySlot = {}
      return unless @parentEvent.childCount

      if @visibleSlots.length
        firstRendered = max([1, first(@visibleSlots) - @padding])
        lastRendered = min([last(@visibleSlots) + @padding, @parentEvent.childCount])
      else
        if @startAtBeginning()
          firstRendered = 1
          lastRendered = 1 + @padding
        else
          firstRendered = max([1, @parentEvent.childCount - @padding])
          lastRendered = @parentEvent.childCount

      firstSlot = max([1, firstRendered - (@padding * 2)])
      lastSlot = min([lastRendered + (@padding * 2), @parentEvent.childCount])

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
      @eventsBySlot[@focusedEvent.position] = @focusedEvent if @focusedEvent
      @slots = [firstSlot..lastSlot]
      if @discussion.newestFirst && @parentEvent.depth == 0
        @slots = reverse([firstSlot..lastSlot])


    slotVisible: (isVisible, entry, slot, event) ->
      slot = parseInt(slot)
      if isVisible
        @visibleSlots = sortedUniq(sortBy(@visibleSlots.concat([slot])))
      else
        @visibleSlots = without(@visibleSlots, slot)

  watch:
    visibleSlots: (newVal, oldVal) ->
      @renderSlots() unless isEqual(newVal, oldVal)

    missingSlots: (newVal, oldVal) ->
      @fetchMissing() unless isEqual(newVal, oldVal)

</script>
