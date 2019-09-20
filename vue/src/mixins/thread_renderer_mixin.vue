<script lang="coffee">
import { throttle, debounce, map, range, min, max, times, first, last, sortedUniq, sortBy, difference, isNumber, isEqual, uniq, without } from 'lodash'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import RecordLoader from '@/shared/services/record_loader'

export default
  created: ->
    @loader = new RecordLoader
      collection: 'events'

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
    padding: 10
    focusedEvent: null

  methods:
    renderSlots: ->
      @eventsBySlot = {}
      times @parentEvent.childCount, (i) =>
        @eventsBySlot[i+1] = null

      minRendered = max([1, (first(@visibleSlots) || 1) - @padding])
      maxRendered = min([(last(@visibleSlots) || 1) + @padding, @parentEvent.childCount])

      presentPositions = []
      Records.events.collection.chain().
      find(parentId: @parentEvent.id).
      find(position: {$between: [minRendered, maxRendered]}).
      simplesort('position').
      data().forEach (event) =>
        presentPositions.push(event.position)
        @eventsBySlot[event.position] = event

      expectedPositions = range(minRendered, maxRendered+1)
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
