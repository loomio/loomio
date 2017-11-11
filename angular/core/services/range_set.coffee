angular.module('loomioApp').factory 'RangeSet', ->
  new class RangeSet
    parse: (outer) ->
      _.map(outer.split(','), (pair) -> _.map(pair.split('-'), (s) -> parseInt(s)))

    serialize: (ranges) ->
      _.map(ranges, (range) -> range.join('-')).join(',')

    reduce: (ranges) ->
      ranges = _.sortBy ranges, (r) -> r[0]
      reduced = [ranges.shift()]
      _.each ranges, (r) ->
        lastr = _.last(reduced)
        if lastr[1] >= (r[0] - 1)
          reduced.pop()
          reduced.push [lastr[0], _.max([r[1], lastr[1]])]
        else
          reduced.push r
      reduced

    overlaps: (a, b) ->
      ab = _.sortBy [a, b], (r) -> r[0]
      ab[0][1] >= ab[1][0]

    includesValue: (ranges, value) ->
      _.any ranges, (range) ->
        _.inRange(value, range[0], range[1]+1)

    subtractRange: (whole, part) ->
      return [whole]                                        if (part.length == 0) || (part[0] > whole[1]) || (part[1] < whole[0])
      return []                                             if (part[0] <= whole[0]) && (part[1] >= whole[1])
      return [[whole[0], part[0]-1], [part[1]+1, whole[1]]] if (part[0] >  whole[0]) && (part[1] <  whole[1])
      return [[part[1] + 1, whole[1] ]]                     if (part[0] == whole[0]) && (part[1] <  whole[1])
      return [[whole[0], part[0]-1]]                        if (part[0] >  whole[0]) && (part[1] == whole[1])

    subtractRanges: (wholes, parts) ->
      output = wholes
      while @subtractRangesLoop(output, parts) != output
        output = @subtractRangesLoop(output, parts)
      @reduce output

    subtractRangesLoop: (wholes, parts) ->
      output = []
      _.each wholes, (whole) =>
        if _.any(parts, (part) => @overlaps(whole, part))
          _.each _.select(parts, (part) => @overlaps(whole, part)), (part) =>
            _.each @subtractRange(whole, part), (remainder) =>
              output.push remainder
        else
          output << whole
      output

    selfTest: ->
      serialize: @serialize([[1,2], [4,5]]) == "1-2,4-5"
      parse:          _.isEqual(@parse("1-2,4-5"),            [[1,2],[4,5]])
      reduce:         _.isEqual(@reduce([[1,2],[3,4]]),       [[1,4]])
      subtractWhole:  _.isEqual(@subtractRange([1,1], [1,1]), [])
      subtractNone:   _.isEqual(@subtractRange([1,1], [2,2]), [[1,1]])
      subtractLeft:   _.isEqual(@subtractRange([1,2], [1,1]), [[2,2]])
      subtractRight:  _.isEqual(@subtractRange([1,2], [2,2]), [[1,1]])
      subtractMiddle: _.isEqual(@subtractRange([1,3], [2,2]), [[1,1], [3,3]])
      # @subtractRanges([[1,1]], [[1,1]]) == []
      # @subtractRanges([[1,2]], [[1,1]]) == [[2,2]]
      # @subtractRanges([[1,2], [4,6]], [[1,1], [5,5]]) == [[2,2], [4,4], [6,6]]
      # @subtractRanges([[1,2], [4,8]], [[5,6], [7,8]]) == [[1,2], [4,4]]
