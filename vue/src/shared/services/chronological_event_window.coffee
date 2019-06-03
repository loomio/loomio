import Records         from '@/shared/services/records'
import RangeSet from '@/shared/services/range_set'
# import RecordLoader    from '@/shared/services/record_loader'
import BaseEventWindow from '@/shared/services/base_event_window'

export default class ChronologicalEventWindow extends BaseEventWindow
  constructor: ({discussion, initialSequenceId, per}) ->
    super(discussion: discussion, per: per)
    @columnName = 'sequenceId'
    @setMin(initialSequenceId)
    @setMax(@min + @per)

  numTotal:        -> @discussion.itemsCount
  firstInSequence: -> @discussion.firstSequenceId()
  lastInSequence:  -> @discussion.lastSequenceId()
  windowLength:      ->
    # how many records should exist between min and max?
    ranges = _.clone(@discussion.ranges)
    if @min > @firstInSequence()
      ranges = RangeSet.subtractRanges(ranges, [[@firstInSequence(), @min - 1]])

    if @max && @max < @lastInSequence()
      ranges = RangeSet.subtractRanges(ranges, [[@max, @lastInSequence()]])

    RangeSet.length(ranges)


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
