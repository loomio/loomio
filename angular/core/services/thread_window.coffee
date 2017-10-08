angular.module('loomioApp').factory 'ThreadWindow', (Records, RecordLoader, $rootScope) ->
  class ThreadWindow
    reset: ->
      @per = 30
      @orderBy = 'createdAt'
      @minSequenceId = @discussion.lastReadSequenceId || 1
      @maxSequenceId = @minSequenceId - 1
      @increaseMax()

    constructor: ({@discussion}) ->
      @reset()
      @loader = new RecordLoader
        collection: 'events'
        params:
          discussion_key: @discussion.key
        per: @per
        from: @minSequenceId
        then: (data) ->
          $rootScope.$broadcast 'threadPageEventsLoaded'
      @loader.loadFrom(@minSequenceId)

    increaseMax: =>
      @maxSequenceId += @per
      if @maxSequenceId >= @discussion.lastSequenceId
        @maxSequenceId = null # allows new events to show up

    decreaseMin: ->
      @minSequenceId -= @per
      if @minSequenceId < @discussion.firstSequenceId
        @minSequenceId = @discussion.firstSequenceId

    anyNext: ->
      @maxSequenceId != null

    loadNext: ->
      if @anyNext()
        @loader.loadFrom(@maxSequenceId).then @increaseMax

    anyPrevious: ->
      @minSequenceId > @discussion.firstSequenceId

    loadPrevious: ->
      if @anyPrevious()
        @decreaseMin()
        @loader.loadFrom(@minSequenceId)

    numPrevious: ->
      @minSequenceId - @discussion.firstSequenceId

    pageOf: (event) ->
      parseInt(event.sequenceId / @per)

    rootsAndOrphans: (event) =>
      (!event.parentId? || event.parent().kind == "new_discussion") ||
      (@pageOf(event) != @pageOf(event.parent()))

    events: =>
      query =
        sequenceId:
          $between: [@minSequenceId, (@maxSequenceId || Number.MAX_VALUE)]
        discussionId: @discussion.id

      events = Records.events.collection.find(query)
      _.filter(events, @rootsAndOrphans)

    noEvents: ->
        !_.any(@events())
