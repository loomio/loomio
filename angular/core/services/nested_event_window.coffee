angular.module('loomioApp').factory 'NestedEventWindow', (BaseEventWindow, Records, RecordLoader) ->
  class NestedEventWindow extends BaseEventWindow
    constructor: ({@discussion, @parentEvent, @initialSequenceId, @per}) ->
      super(discussion: @discussion, per: @per)
      @setMin(@positionFromSequenceId(@initialSequenceId) || @firstLoaded())
      @setMax(@lastLoaded() || false)
      @loader = new RecordLoader
        collection: 'events'
        params:
          discussion_id: @discussion.id
          parent_id: @parentEvent.id
          order: 'position'
          per: @per

    positionFromSequenceId: ->
      initialEvent = Records.events.find(discussionId: @discussion.id, sequenceId: @initialSequenceId)[0]
      # ensure that we set the min position of the window to bring the initialSequenceId to the top
      # if this is the outside window, then the initialEvent might be nested, in which case, position to the parent of initialEvent
      # if the initialEvent is not child of our parentEvent

      # if the initialEvent is a child of the parentEvent then min = initialEvent.position
      # if the initialEvent is a grandchild of the parentEvent then min = initialEvent.parent().position
      # if the initialEvent is not a child or grandchild, then min = 0
      if initialEvent.parentId == @parentEvent.id
        initialEvent.position
      else if initialEvent.parent().parentId == @parentEvent.id
        initialEvent.parent().position
      else
        0

    useNesting: true

    # min and max are the minimum and maximum values permitted in the window
    setMin: (val) ->
      @min = val
      @min = 1 if @min < 1

    setMax: (val) ->
      @max = val
      @max = false if @max > @parentEvent.childCount

    # first, last, total are the values we actually have - within the window
    firstLoaded: -> (_.first(@events()) || {}).position || 0
    lastLoaded:  -> (_.last(@events())  || {}).position || 0
    totalLoaded: -> @events().length
    anyLoaded:   -> @totalLoaded() > 0

    # do any previous events exist outside of what is loaded?
    anyPrevious: -> @parentEvent.childCount > 0 && @firstLoaded() > 1
    numPrevious: -> @parentEvent.childCount > 0 && @firstLoaded() - 1
    anyNext:     -> @parentEvent.childCount > @lastLoaded()
    numNext:     -> @parentEvent.childCount - @lastLoaded()
    anyMissing:  -> @parentEvent.childCount > @totalLoaded()
    numMissing:  -> @parentEvent.childCount - @totalLoaded()

    allEvents: ->
      Records.events.collection.chain().find(parentId: @parentEvent.id).simplesort('position').data()

    events: ->
      query =
        parentId: @parentEvent.id
        position:
          $between: [@min, (@max || Number.MAX_VALUE)]

      Records.events.collection.chain().find(query).simplesort('position').data()

    loadNext:  ->
      @setMax(@max + @per)
      @loader.loadMore(@lastLoaded()+1)

    loadPrevious: ->
      @setMin(@firstLoaded() - @per)
      @loader.loadPrevious(@min)
