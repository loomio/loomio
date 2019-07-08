
export default new class RangeSet
  parse: (outer) ->
    _.map(outer.split(','), (pair) -> _.map(pair.split('-'), (s) -> parseInt(s)))

  serialize: (ranges) ->
    _.map(ranges, (range) -> range.join('-')).join(',')

  reduce: (ranges) ->
    ranges = _.sortBy ranges, (r) -> r[0]
    reduced = _.compact [ranges.shift()]
    _.each ranges, (r) ->
      lastr = _.last(reduced)
      if lastr[1] >= (r[0] - 1)
        reduced.pop()
        reduced.push [lastr[0], _.max([r[1], lastr[1]])]
      else
        reduced.push r
    reduced

  length: (ranges) ->
    _.sum _.map(ranges, (range) -> range[1] - range[0] + 1)

  arrayToRanges: (ary) -> @reduce(ary.map (id) -> [id,id] )

  intersectRanges: (readRanges, ranges) ->
    # remove any items in readRanges that do not exist in ranges
    @arrayToRanges(@rangesToArray(readRanges).filter (v) => @includesValue(ranges, v))

  rangesToArray: (ranges) ->
    list = []
    ranges.forEach (range) =>
      list = list.concat(@rangeToArray(range[0], range[1], 1))
    list

  # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/from
  rangeToArray: (start, stop, step) ->
    Array.from({length: (stop - start) / step + 1}, (_, i) => start + (i * step));

  overlaps: (a, b) ->
    ab = _.sortBy [a, b], (r) -> r[0]
    ab[0][1] >= ab[1][0]

  includesValue: (ranges, value) ->
    _.some ranges, (range) ->
      _.inRange(value, range[0], range[1]+1)

  # TODO: fix me for complex range sets!
  subtractRange: (whole, part) ->
    return [whole]                                        if (part.length == 0) || (part[0] > whole[1]) || (part[1] < whole[0])
    return []                                             if (part[0] <= whole[0]) && (part[1] >= whole[1])
    return [[whole[0], part[0]-1], [part[1]+1, whole[1]]] if (part[0] >  whole[0]) && (part[1] <  whole[1])
    return [[part[1] + 1, whole[1]]]                      if (part[0] == whole[0]) && (part[1] <  whole[1])
    return [[whole[0], part[0]-1]]                        if (part[0] >  whole[0]) && (part[1] == whole[1])

  subtractRanges: (wholes, parts) ->
    output = wholes
    while !_.isEqual(@subtractRangesLoop(output, parts), output)
      output = @subtractRangesLoop(output, parts)
    @reduce output

  subtractRangesLoop: (wholes, parts) ->
    output = []
    _.each wholes, (whole) =>
      if _.some(parts, (part) => @overlaps(whole, part))
        _.each _.filter(parts, (part) => @overlaps(whole, part)), (part) =>
          _.each @subtractRange(whole, part), (remainder) =>
            output.push remainder
      else
        output.push whole
    output

  firstMissing: (superset, subset) =>
    [supersetRange, subsetRange] = @firstMissingRange @reduce(superset), @reduce(subset)
    return unless supersetRange and subsetRange

    if subsetRange[0] > supersetRange[0]
      # return the beginning of the superset range if the subset range does not cover it
      supersetRange[0]
    else
      # otherwise return the first value the subset range does not cover
      subsetRange[1] + 1

  # returns the first range in the subset which does not match the superset's ranges
  firstMissingRange: (superset, subset) ->
    for supersetRange in superset
      if !_.find subset, supersetRange
        subsetRange = _.head _.filter subset, (range) -> range[0] >= supersetRange[0]
        return [supersetRange, subsetRange]
    []

  # # err need to exrtact this to an npm module
  # selfTest: ->
  #   length1:                    @length([1,1]) == 1
  #   length2:                    @length([1,2]) == 2
  #   serialize:                 @serialize([[1,2], [4,5]]) == "1-2,4-5"
  #   parse:           _.isEqual @parse("1-2,4-5"),                 [[1,2],[4,5]]
  #   reduceSimple:    _.isEqual @reduce([[1,1]]), [[1,1]]
  #   reduceMerge:     _.isEqual @reduce([[1,2],[3,4]]),            [[1,4]]
  #   reduceEmpty:     _.isEqual @reduce([]), []
  #   subtractWhole:   _.isEqual @subtractRange([1,1], [1,1]),      []
  #   subtractNone:    _.isEqual @subtractRange([1,1], [2,2]),      [[1,1]]
  #   subtractLeft:    _.isEqual @subtractRange([1,2], [1,1]),      [[2,2]]
  #   subtractRight:   _.isEqual @subtractRange([1,2], [2,2]),      [[1,1]]
  #   subtractMiddle:  _.isEqual @subtractRange([1,3], [2,2]),      [[1,1], [3,3]]
  #   overlapsNone:              @overlaps([1,2], [3,4]) == false
  #   overlapsPart:              @overlaps([1,2], [2,3]) == true
  #   overlapsWhole:             @overlaps([1,2], [1,2]) == true
  #   subtractRanges1: _.isEqual @subtractRanges([[1,1]], [[1,1]]), []
  #   subtractRanges2: _.isEqual @subtractRanges([[1,2]], [[1,1]]), [[2,2]]
  #   subtractRanges3: _.isEqual @subtractRanges([[1,2], [4,6]], [[1,1], [5,5]]), [[2,2], [4,4], [6,6]]
  #   subtractRanges4: _.isEqual @subtractRanges([[1,2], [4,8]], [[5,6], [7,8]]), [[1,2], [4,4]]
  #   firstMissing0:   _.isEqual @firstMissing([[1,3]], [[1,3]]), undefined
  #   firstMissing1:   _.isEqual @firstMissing([[1,3]], [[1,2]]), 3
  #   firstMissing2:   _.isEqual @firstMissing([[1,3]], [[2,3]]), 1
  #   firstMissing3:   _.isEqual @firstMissing([[1,2], [4,6]], [[1,2], [4,5]]), 6
  #   firstMissing4:   _.isEqual @firstMissing([[1,2], [4,6]], [[1,2], [5,6]]), 4
