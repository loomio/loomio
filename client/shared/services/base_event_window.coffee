RangeSet = require 'shared/services/range_set'

module.exports = class BaseEventWindow
  constructor: ({discussion, per}) ->
    @discussion = discussion
    @per        = per
    @readRanges = _.clone(@discussion.readRanges)

  # to be implemented by the super class
  # firstInSequence
  # lastInSequence
  # numTotal

  # methods about what the client has loaded
  firstLoaded:       -> (_.head(@loadedEvents()) || {})[@columnName] || 0
  lastLoaded:        -> (_.last(@loadedEvents())  || {})[@columnName] || 0
  numLoaded:         -> @loadedEvents().length
  anyLoaded:         -> @numLoaded() > 0
  # these are correct, but unused
  # canLoadPrevious:   -> @numTotal() > 0 && @firstLoaded() > @firstInSequence()
  # canLoadNext:       -> @numTotal() > 0 && @lastInSequence() > @lastLoaded()
  # numToLoadPrevious: -> @firstLoaded() - @firstInSequence()
  # numToLoadNext:     -> @lastInSequence() - @lastLoaded()
  # anyMissing:        -> @numTotal() > @numLoaded()
  # numMissing:        -> @numTotal() - @numLoaded()

  # methods about what is read
  numRead:           -> RangeSet.length(@readRanges)
  numUnread:         -> @numTotal() - @numRead()
  anyUnread:         -> @numUnread() > 0

  # min and max are the minimum and maximum values permitted in the window
  setMin: (val) -> @min = _.max([val, @firstInSequence()])
  setMax: (val) -> @max = if val < @lastInSequence() then val else false

  isUnread: (event) =>
    !_.some @readRanges, (range) ->
      _.inRange(event.sequenceId, range[0], range[1]+1)

  increaseMax: =>
    return false if @max == false
    @setMax(@max + @per)

  decreaseMin: =>
    return false unless @min > @firstInSequence()
    @setMin(@min - @per)

  # these talk about the window over the events
  windowNumNext:   -> if @max == false then 0 else @lastInSequence() - @max
  numPrevious:     -> _.max([@min - @firstInSequence(), @firstLoaded() - @firstInSequence()])
  numNext:         -> _.max([@windowNumNext(), @lastInSequence() - @lastLoaded()])
  anyPrevious:     -> @numPrevious() > 0
  anyNext:         -> @numNext() > 0

  showNext:  ->
    @increaseMax()
    if (@max > @lastLoaded()) || ((@max == false) && (@lastLoaded() < @numTotal()))
      @loader.loadMore(@lastLoaded()+1)

  showPrevious: ->
    @decreaseMin()
    @loader.loadPrevious(@min) # if @min < @firstLoaded() # if we don't already have all the records.

  showAll: ->
    @loader.params.per = Number.MAX_SAFE_INTEGER
    @setMin(@firstInSequence())
    @setMax(Number.MAX_SAFE_INTEGER)
    @loader.loadMore(@min)
