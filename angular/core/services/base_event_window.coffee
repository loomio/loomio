angular.module('loomioApp').factory 'BaseEventWindow', ->
  class BaseEventWindow
    constructor: ({@discussion, @per}) ->
      @readRanges = _.clone(@discussion.readRanges)

    isUnread: (event) =>
      !_.any @readRanges, (range) ->
        _.inRange(event.sequenceId, range[0], range[1]+1)

    noEvents: ->
      @events().length == 0

    increaseMax: =>
      return false unless @max
      @setMax(@max + @per)

    decreaseMin: =>
      @setMin(@min - @per)
