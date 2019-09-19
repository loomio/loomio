<script lang="coffee">
import { debounce, min, max, times, difference, isNumber, isEqual, uniq, without } from 'lodash'
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'

export default
  created: ->
    EventBus.$on 'focusedEvent', (event) =>
      @focusedEvent = event          if event.parentId == @parentEvent.id
      @focusedEvent = event.parent() if event.parent() && event.parent().parentId == @parentEvent.id

  data: ->
    eventsBySlot: {}
    visibleSlots: []
    minRendered: 0
    maxRendered: 0
    pageSize: 10
    focusedEvent: null

  methods:
    renderSlots: ->
      return unless @parentEvent

      @eventsBySlot = {}
      times @parentEvent.childCount, (i) =>
        @eventsBySlot[i+1] = null

      Records.events.collection.chain().
        # find(discussionId: @parentEvent.discussionId).
        find(parentId: @parentEvent.id).
        find(position: {$gte: @minRendered}).
        find(position: {$lte: @maxRendered}).
        data().forEach (event) =>
          @eventsBySlot[event.position] = event

      @eventsBySlot[@focusedEvent.position] = @focusedEvent if @focusedEvent

    slotVisible: (isVisible, entry, slot, event) ->
      slot = parseInt(slot)
      if isVisible
        @visibleSlots = uniq(@visibleSlots.concat([slot])).sort()
      else
        @visibleSlots = without @visibleSlots, slot

    haveAllEventsBetween: (column, min, max) ->
      # expectedLength = switch column
      #   when 'position' then (max - min) + 1
      #   when 'sequenceId' then console.error('sequenceId not implemented yet')
      expectedLength = (max - min) + 1
      length = Records.events.collection.chain().
        find(parentId: @parentEvent.id).
        find(position: {$between: [min, max]}).data().length

      # console.log "haveAllEventsBetween", length == expectedLength, min, max
      length == expectedLength

    updateRendered: (minVisible, maxVisible) ->
      @minRendered = max([1, minVisible - @pageSize])
      @maxRendered = min([maxVisible + @pageSize, @parentEvent.childCount])

      # console.log @parentEvent.model().body
      # console.log 'visible', minVisible, maxVisible
      # console.log 'rendered', @minRendered, @maxRendered
      @renderSlots()
      @fetchMissing()

  watch:
    visibleSlots: (newVal, oldVal) ->
      return if isEqual(newVal, oldVal)
      minVisible = min(newVal) || 1
      maxVisible = max(newVal) || 1
      @updateRendered(minVisible, maxVisible)

</script>
