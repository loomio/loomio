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
      @anyMissing() && !@noneLoaded() && @firstPosition() > 0

    anyNext: ->
      @anyMissing() &&
      (@noneLoaded() || (@lastPosition() + 1) < @parentEvent.childCount)

    previousCount: ->
      if @anyPrevious()
        @firstPosition()
      else
        0

    nextCount: ->
      if !@anyNext()
        0
      else if @noneLoaded()
        @parentEvent.childCount
      else
        @parentEvent.childCount - (@lastPosition() + 1)

    firstPosition: ->
      (_.first(@events()) || {}).position

    lastPosition: ->
      (_.last(@events()) || {}).position

    loadMore:  ->
      @showMore = true
      @loader.loadMore()

    loadPrevious: ->
      @showMore = true
      @loader.loadPrevious()

    showLess: ->
      @showMore = false
