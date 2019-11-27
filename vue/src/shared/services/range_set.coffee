import {each, isEqual, last, max, map, sum, some, filter, compact, sortBy, inRange} from 'lodash'

export default new class RangeSet
  parse: (outer) ->
    map(outer.split(','), (pair) -> map(pair.split('-'), (s) -> parseInt(s)))

  serialize: (ranges) ->
    map(ranges, (range) -> range.join('-')).join(',')

  reduce: (ranges) ->
    ranges = sortBy ranges, (r) -> r[0]
    reduced = compact [ranges.shift()]
    each ranges, (r) ->
      lastr = last(reduced)
      if lastr[1] >= (r[0] - 1)
        reduced.pop()
        reduced.push [lastr[0], max([r[1], lastr[1]])]
      else
        reduced.push r
    reduced

  length: (ranges) ->
    sum map(ranges, (range) -> range[1] - range[0] + 1)

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
    Array.from({length: (stop - start) / step + 1}, (_, i) -> start + (i * step))

  overlaps: (a, b) ->
    ab = sortBy [a, b], (r) -> r[0]
    ab[0][1] >= ab[1][0]

  includesValue: (ranges, value) ->
    some ranges, (range) ->
      inRange(value, range[0], range[1] + 1)

  # TODO: fix me for complex range sets!
  subtractRange: (whole, part) ->
    return [whole]                                        if (part.length == 0) || (part[0] > whole[1]) || (part[1] < whole[0])
    return []                                             if (part[0] <= whole[0]) && (part[1] >= whole[1])
    return [[whole[0], part[0] - 1], [part[1] + 1, whole[1]]] if (part[0] >  whole[0]) && (part[1] <  whole[1])
    return [[part[1] + 1, whole[1]]]                      if (part[0] == whole[0]) && (part[1] <  whole[1])
    return [[whole[0], part[0] - 1]]                      if (part[0] >  whole[0]) && (part[1] == whole[1])

  subtractRanges: (wholes, parts) ->
    output = wholes
    while !isEqual(@subtractRangesLoop(output, parts), output)
      output = @subtractRangesLoop(output, parts)
    @reduce output

  subtractRangesLoop: (wholes, parts) ->
    output = []
    each wholes, (whole) =>
      if some(parts, (part) => @overlaps(whole, part))
        each filter(parts, (part) => @overlaps(whole, part)), (part) =>
          each @subtractRange(whole, part), (remainder) ->
            output.push remainder
      else
        output.push whole
    output

  firstMissing: (ranges, readRanges) =>
    @rangesToArray(ranges).find (v) => !@includesValue(readRanges, v)

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
