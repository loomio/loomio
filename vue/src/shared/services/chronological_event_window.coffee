import Records         from '@/shared/services/records'
import RecordLoader    from '@/shared/services/record_loader'
import BaseEventWindow from '@/shared/services/base_event_window'

export default class ChronologicalEventWindow extends BaseEventWindow
  constructor: ({discussion, initialSequenceId, per}) ->
    super(discussion: discussion, per: per)
    @columnName = 'sequenceId'
    @setMin(initialSequenceId)
    @setMax(@min + @per)
    @loader = new RecordLoader
      collection: 'events'
      params:
        discussion_id: @discussion.id
        order: 'sequence_id'
        per: @per

  numTotal:        -> @discussion.itemsCount
  firstInSequence: -> @discussion.firstSequenceId()
  lastInSequence:  -> @discussion.lastSequenceId()

  eventsQuery: ->
    query =
      discussionId: @discussion.id
    Records.events.collection.chain().find(query)

  loadedEvents: ->
    @eventsQuery().simplesort('sequenceId').data()

  windowedEvents: =>
    windowQuery =
      sequenceId:
        $between: [@min, (@max || Number.MAX_VALUE)]
    @eventsQuery().find(windowQuery).simplesort('sequenceId').data()
