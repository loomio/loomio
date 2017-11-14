angular.module('loomioApp').factory 'BaseEventWindow', ->
  class BaseEventWindow
    constructor: ({@discussion, @per}) ->
      @readRanges = _.clone(@discussion.readRanges)

    firstLoaded: -> (_.first(@events()) || {})[@columnName] || 0
    lastLoaded:  -> (_.last(@events())  || {})[@columnName] || 0

    # min and max are the minimum and maximum values permitted in the window
    setMin: (val) ->
      @min = val
      @min = @firstInSequence() if @min < @firstInSequence()

    setMax: (val) ->
      @max = val
      @max = false if @max > @lastInSequence()

    totalLoaded: -> @events().length
    anyLoaded:   -> @totalLoaded() > 0

    # do any previous events exist outside of what is loaded?
    anyPrevious: -> @numTotal() > 0 && @firstLoaded() > 1
    numPrevious: -> @numTotal() > 0 && @firstLoaded() - 1
    anyNext:     -> @numTotal() > @lastLoaded()
    numNext:     -> @numTotal() - @lastLoaded()
    anyMissing:  -> @numTotal() > @totalLoaded()
    numMissing:  -> @numTotal() - @totalLoaded()

    isUnread: (event) =>
      !_.any @readRanges, (range) ->
        _.inRange(event.sequenceId, range[0], range[1]+1)

    # change to noneLoaded()
    noEvents: ->
      @events().length == 0

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
