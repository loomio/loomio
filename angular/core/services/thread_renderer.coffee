angular.module('loomioApp').factory 'ThreadRenderer', (Records, RecordLoader, $rootScope) ->
  class ThreadRenderer
    constructor: ({@scope, @per, @discussion}) ->
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

    reset: ->
      @orderBy = 'createdAt'
      @minSequenceId = @discussion.lastReadSequenceId || 1
      @maxSequenceId = @minSequenceId - 1
      @increaseMax()

    increaseMax: =>
      @maxSequenceId += @per
      if @maxSequenceId >= @discussion.lastSequenceId
        @maxSequenceId = null # allows new events to show up

    decreaseMin: ->
      @minSequenceId -= @per
      if @minSequenceId < @discussion.firstSequenceId
        @minSequenceId = @discussion.firstSequenceId

    canloadNext: ->
      @maxSequenceId != null

    loadNext: ->
      if @canloadNext()
        @loader.loadFrom(@maxSequenceId).then @increaseMax

    canLoadPrevious: ->
      @minSequenceId > @discussion.firstSequenceId

    loadPrevious: ->
      if @canLoadPrevious()
        @decreaseMin()
        @loader.loadFrom(@minSequenceId)

    numPrevious: ->
      @minSequenceId - @discussion.firstSequenceId

    pageOf: (event) ->
      parseInt(event.sequenceId / (@per + 1))

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
