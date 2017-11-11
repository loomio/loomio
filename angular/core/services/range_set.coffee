angular.module('loomioApp').factory 'RangeSet', ->
  new class RangeSet
    parse: (str) ->
      _.map(str.split(','), (pair_str) -> pair_str.split('-'))

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

    includesValue: (ranges, value) ->
      _.any ranges, (range) ->
        _.inRange(value, range[0], range[1]+1)
