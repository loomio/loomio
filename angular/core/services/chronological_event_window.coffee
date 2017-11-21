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


    fewerDiscussionEditedEvents: (events) ->
      _.reject events, (event) =>
        event.kind == "discussion_edited" &&
        (event.position == 0 || (event.previous() || {}).kind == "discussion_edited")

    events: =>
      query =
        sequenceId:
          $between: [@min, (@max || Number.MAX_VALUE)]
        discussionId: @discussion.id

      events = Records.events.collection.chain().find(query).simplesort('id').data()
      _.uniq(@fewerDiscussionEditedEvents( events))
