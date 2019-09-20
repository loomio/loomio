<script lang="coffee">
import { throttle, debounce, map, range, min, max, times, first, last, sortedUniq, sortBy, difference, isNumber, isEqual, uniq, without } from 'lodash'
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
    padding: 20
    focusedEvent: null

  methods:
    renderSlots: ->
      firstRendered = max([1, (first(@visibleSlots) || 1) - @padding])
      lastRendered = min([(last(@visibleSlots) || 1) + @padding, @parentEvent.childCount])

      firstSlot = max([1, firstRendered - (@padding * 2)])
      lastSlot = min([lastRendered + (@padding * 2), @parentEvent.childCount])

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
      @eventsBySlot[@focusedEvent.position] = @focusedEvent if @focusedEvent

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
