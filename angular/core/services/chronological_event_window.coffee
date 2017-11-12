angular.module('loomioApp').factory 'ChronologicalEventWindow', (BaseEventWindow, Records, RecordLoader) ->
  class ChronologicalEventWindow extends BaseEventWindow
    constructor: ({@discussion, @settings}) ->
      super(discussion: @discussion, settings: @settings)
      @setMin(@settings.initialSequenceId || 1)
      @setMax(@min - 1)
      @loader = new RecordLoader
        collection: 'events'
        params:
          discussion_key: @discussion.key
        per: @settings.per
        from: @min

    setMin: (val) ->
      @min = val
      if @min < @discussion.firstSequenceId()
        @min = @discussion.firstSequenceId

    setMax: (val) ->
      @max = val
      if @max >= @discussion.lastSequenceId()
        @max = false # allows new events to show up

    increaseMax: =>
      @setMax((@max || 0) + @settings.per)

    decreaseMin: =>
      @setMin(@min -= @per)

    anyNext: -> @max

    loadNext: ->
      @loader.loadMore(@max).then(@increaseMax)

    anyPrevious: ->
      @min > @discussion.firstSequenceId

    loadPrevious: ->
      @decreaseMin()
      @loader.loadPrevious(@min)

    numPrevious: ->
      # possibly inaccurate. might remove
      @min - @discussion.firstSequenceId

    loadAll: ->
      @loader.per = Number.MAX_SAFE_INTEGER
      @min = @discussion.firstSequenceId
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
