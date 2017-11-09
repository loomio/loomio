angular.module('loomioApp').factory 'NestedEventWindow', (BaseEventWindow, Records, RecordLoader) ->
  class NestedEventWindow extends BaseEventWindow
    constructor: ({@discussion, @parentEvent, @settings}) ->
      super(discussion: @discussion, settings: @settings)
      @loader = new RecordLoader
        collection: 'events'
        params:
          parent_id: @parentEvent.id
          discussion_key: @discussion.key
          max_depth: @parentEvent.depth + 1
        per: @settings.per
        from: @settings.initialSequenceId
      if @settings.position == "unread"
        @loader.params.exclude_sequence_ids =
          _.map(@discussion.readRanges, (range) -> range.join(',')).join(' ')

    useNesting: true

    events: ->
      query =
        parentId: @parentEvent.id
        sequenceId:
          $between: [@settings.minSequenceId,
                     (@settings.maxSequenceId || Number.MAX_VALUE)]
      delete query.sequenceId if @showMore
      Records.events.collection.find(query)

    anyMissing: ->
      @parentEvent.childCount > 0 &&
      @events().length < @parentEvent.childCount

    anyPrevious: ->
      @anyMissing() && !@noEvents() && @firstPosition() > 0

    anyNext: ->
      @anyMissing() &&
      (@noEvents() || (@lastPosition() + 1) < @parentEvent.childCount)

    previousCount: ->
      if @anyPrevious()
        @firstPosition()
      else
        0

    nextCount: ->
      if !@anyNext()
        0
      else if @noEvents()
        @parentEvent.childCount
      else
        @parentEvent.childCount - (@lastPosition() + 1)

    firstPosition: ->
      (_.first(@events()) || {}).position

    lastPosition: ->
      (_.last(@events()) || {}).position

    loadNext:  ->
      @showMore = true
      @loader.loadMore()

    loadPrevious: ->
      @showMore = true
      @loader.loadPrevious()

    showLess: ->
      @showMore = false
