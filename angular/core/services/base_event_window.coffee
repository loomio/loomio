angular.module('loomioApp').factory 'BaseEventWindow', ->
  class BaseEventWindow
    constructor: ({@discussion, @per}) ->
      @readRanges = _.clone(@discussion.readRanges)

    # firstInSequence
    # lastInSequence
    # numTotal        are implemented by the inheriting class
    firstLoaded: -> (_.first(@events()) || {})[@columnName] || 0
    lastLoaded:  -> (_.last(@events())  || {})[@columnName] || 0
    numLoaded:   -> @events().length
    anyLoaded:   -> @numLoaded() > 0
    anyPrevious: -> @numTotal() > 0 && @firstLoaded() > 1
    numPrevious: -> @numTotal() > 0 && @firstLoaded() - 1
    anyNext:     -> @numTotal() > @lastLoaded()
    numNext:     -> @numTotal() - @lastLoaded()
    anyMissing:  -> @numTotal() > @numLoaded()
    numMissing:  -> @numTotal() - @numLoaded()

    # min and max are the minimum and maximum values permitted in the window
    setMin: (val) ->
      @min = val
      @min = @firstInSequence() if @min < @firstInSequence()

    setMax: (val) ->
      @max = val
      @max = false if @max > @lastInSequence()

    isUnread: (event) =>
      !_.any @readRanges, (range) ->
        _.inRange(event.sequenceId, range[0], range[1]+1)

    increaseMax: =>
      return false unless @max
      @setMax(@max + @per)

    decreaseMin: =>
      @setMin(@min - @per)

    loadNext:  ->
      @setMax(@max + @per)
      @loader.loadMore(@lastLoaded()+1)

    loadPrevious: ->
      @setMin(@firstLoaded() - @per)
      @loader.loadPrevious(@min)

    loadAll: ->
      @loader.per = Number.MAX_SAFE_INTEGER
      @setMin(@firstInSequence())
      @setMax(Number.MAX_SAFE_INTEGER)
      @loader.loadMore(@min)
