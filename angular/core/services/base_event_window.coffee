angular.module('loomioApp').factory 'BaseEventWindow', (Records, RecordLoader) ->
  class BaseEventWindow
    constructor: ({@discussion, @settings}) ->
      @readRanges = _.clone(@discussion.readRanges)

    isUnread: (event) =>
      !_.any @readRanges, (range) ->
        _.inRange(event.sequenceId, range[0], range[1]+1)

    noEvents: ->
      @events().length == 0
