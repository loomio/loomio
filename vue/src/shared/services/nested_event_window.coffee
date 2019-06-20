import Records         from '@/shared/services/records'
import BaseEventWindow from '@/shared/services/base_event_window'

export default class NestedEventWindow extends BaseEventWindow
  constructor: ({discussion, parentEvent, initialSequenceId, per}) ->
    super(discussion: discussion, per: per)
    @columnName = "position"
    @parentEvent = parentEvent

  useNesting: true

  # first, last, total are the values we actually have - within the window
  numTotal:        -> @parentEvent.childCount
  firstInSequence: -> 1
  lastInSequence:  -> @parentEvent.childCount
  windowLength: ->
    (@max || @lastInSequence()) - (@min - 1)

  eventsQuery: ->
    Records.events.collection.chain().find(parentId: @parentEvent.id)

  loadedEvents: ->
    @eventsQuery().simplesort('position').data()

  # windowed Events
  windowedEvents: ->
    query =
      position:
        $between: [@min, (@max || Number.MAX_VALUE)]
    @eventsQuery().find(query).simplesort('position').data()
