angular.module('loomioApp').factory 'ChronologicalEventWindow', (BaseEventWindow, Records, RecordLoader) ->
  class ChronologicalEventWindow extends BaseEventWindow
    constructor: ({@discussion, @initialSequenceId, @per}) ->
      @columnName = 'sequenceId'
      super(discussion: @discussion, per: @per)
      @setMin(@initialSequenceId)
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
