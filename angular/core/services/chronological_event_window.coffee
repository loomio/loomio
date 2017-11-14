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

    loadAll: ->
      @loader.per = Number.MAX_SAFE_INTEGER
      @min = @discussion.firstSequenceId()
      @max = false
      @loader.loadMore(@min)

    rootsAndOrphans: (events) =>
      _.filter events, (event) => !event.parentId? || !@inWindow(event.parent())

    fewerDiscussionEditedEvents: (events) ->
      _.reject events, (event) =>
        event.kind == "discussion_edited" &&
        (event.position == 0 || (event.previous() || {}).kind == "discussion_edited")

    replaceOrphansWithParents: (events) =>
      _.map events, (event) =>
        if event.parentId? && event.parent().kind != "new_discussion" &&!@inWindow(event.parent())
          event.parent()
        else
          event

    events: =>
      # i think we want to memoize this method eventually
      query =
        sequenceId:
          $between: [@min, (@max || Number.MAX_VALUE)]
        discussionId: @discussion.id

      events = Records.events.collection.chain().find(query).simplesort('id').data()
      # _.uniq( @replaceOrphansWithParents( @rootsAndOrphans( @fewerDiscussionEditedEvents( events))))
      _.uniq(@fewerDiscussionEditedEvents( events))

    inWindow: (event) ->
      event.sequenceId >= @min && ((@max == false) || event.sequenceId <= @max)

    isLastInWindow: (event) ->
      _.last(@events()) == event
