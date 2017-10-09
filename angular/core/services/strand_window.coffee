angular.module('loomioApp').factory 'StrandWindow', (Records, RecordLoader, $rootScope) ->
  class StrandWindow
    constructor: ({@parentEvent, @threadWindow}) ->
      @loader = new RecordLoader
        collection: 'events'
        params:
          parent_id: @parentEvent.id
          discussion_key: @parentEvent.discussion().key
        per: @threadWindow.per

    events: ->
      query =
        parentId: @parentEvent.id
        sequenceId:
          $between: [@threadWindow.minSequenceId,
                     (@threadWindow.maxSequenceId || Number.MAX_VALUE)]
      delete query.sequenceId if @showMore
      Records.events.collection.find(query)

    noneLoaded: ->
      @events().length == 0

    anyMissing: ->
      @parentEvent.childCount > 0 &&
      @events().length < @parentEvent.childCount

    anyPrevious: ->
      @anyMissing() && !@noneLoaded() && @firstPos() > 0

    anyNext: ->
      @anyMissing() &&
      (@noneLoaded() || (@lastPos() + 1) < @parentEvent.childCount)

    previousCount: ->
      if @anyPrevious()
        @firstPos()
      else
        0

    nextCount: ->
      if !@anyNext()
        0
      else if @noneLoaded()
        @parentEvent.childCount
      else
        @parentEvent.childCount - (@lastPos() + 1)

    firstPos: ->
      if @events().length > 0
        @events()[0].pos

    lastPos: ->
      if @events().length > 0
        _.last(@events()).pos

    loadMore:  ->
      @showMore = true
      @loader.loadMore()

    loadPrevious: ->
      @showMore = true
      @loader.loadPrevious()

    showLess: ->
      @showMore = false
