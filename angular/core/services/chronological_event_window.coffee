angular.module('loomioApp').factory 'ChronologicalEventWindow', (BaseEventWindow, Records, RecordLoader) ->
  class ChronologicalEventWindow extends BaseEventWindow
    constructor: ({@discussion, @settings}) ->
      super(discussion: @discussion, settings: @settings)
      @setMin(@settings.initialSequenceId || 1)
      @setMax(@minSequenceId - 1)
      @loader = new RecordLoader
        collection: 'events'
        params:
          discussion_key: @discussion.key
        per: @settings.per
        from: @minSequenceId

    setMin: (val) ->
      @minSequenceId = val
      if @minSequenceId < @discussion.firstSequenceId
        @minSequenceId = @discussion.firstSequenceId

    setMax: (val) ->
      @maxSequenceId = val
      if @maxSequenceId >= @discussion.lastSequenceId
        @maxSequenceId = null # allows new events to show up

    increaseMax: =>
      @setMax(@maxSequenceId += @per)

    decreaseMin: =>
      @setMin(@minSequenceId -= @per)

    anyNext: ->
      @maxSequenceId != null

    loadNext: ->
      @loader.loadMore(@maxSequenceId).then(@increaseMax)

    anyPrevious: ->
      @minSequenceId > @discussion.firstSequenceId

    loadPrevious: ->
      @decreaseMin()
      @loader.loadPrevious(@minSequenceId)

    numPrevious: ->
      @minSequenceId - @discussion.firstSequenceId

    loadAll: ->
      @loader.per = Number.MAX_SAFE_INTEGER
      @minSequenceId = @discussion.firstSequenceId
      @maxSequenceId = null
      @loader.loadMore(@minSequenceId)

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
          $between: [@minSequenceId, (@maxSequenceId || Number.MAX_VALUE)]
        discussionId: @discussion.id

      events = Records.events.collection.find(query)
      _.uniq( @replaceOrphansWithParents( @rootsAndOrphans( @fewerDiscussionEditedEvents( events))))

    inWindow: (event) ->
      event.sequenceId >= @minSequenceId &&
      ((@maxSequenceId == null) || event.sequenceId <= @maxSequenceId)

    isLastInWindow: (event) ->
      _.last(@events()) == event

    isFirstUnread: (event) ->
      event.sequenceId == @firstUnreadSequenceId
