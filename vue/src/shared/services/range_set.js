import {each, isEqual, last, max, map, sum, some, filter, compact, sortBy, inRange} from 'lodash-es';

export default new class RangeSet {
  parse(outer) {
    return map(outer.split(','), pair => map(pair.split('-'), s => parseInt(s)));
  }

  serialize(ranges) {
    return map(ranges, range => range.join('-')).join(',');
  }

  reduce(ranges) {
    ranges = sortBy(ranges, r => r[0]);
    const reduced = compact([ranges.shift()]);
    each(ranges, function(r) {
      const lastr = last(reduced);
      if (lastr[1] >= (r[0] - 1)) {
        reduced.pop();
        return reduced.push([lastr[0], max([r[1], lastr[1]])]);
      } else {
        return reduced.push(r);
      }
    });
    return reduced;
  }

  length(ranges) {
    return sum(map(ranges, range => (range[1] - range[0]) + 1));
  }

  arrayToRanges(ary) { return this.reduce(ary.map(id => [id,id]) ); }

  intersectRanges(readRanges, ranges) {
    // remove any items in readRanges that do not exist in ranges
    return this.arrayToRanges(this.rangesToArray(readRanges).filter(v => this.includesValue(ranges, v)));
  }

  rangesToArray(ranges) {
    let list = [];
    ranges.forEach(range => {
      return list = list.concat(this.rangeToArray(range[0], range[1], 1));
    });
    return list;
  }

  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/from
  rangeToArray(start, stop, step) {
    return Array.from({length: ((stop - start) / step) + 1}, (_, i) => start + (i * step));
  }

  overlaps(a, b) {
    const ab = sortBy([a, b], r => r[0]);
    return ab[0][1] >= ab[1][0];
  }

  includesValue(ranges, value) {
    return some(ranges, range => inRange(value, range[0], range[1] + 1));
  }

  // TODO: fix me for complex range sets!
  subtractRange(whole, part) {
    if ((part.length === 0) || (part[0] > whole[1]) || (part[1] < whole[0])) { return [whole]; }
    if ((part[0] <= whole[0]) && (part[1] >= whole[1])) { return []; }
    if ((part[0] >  whole[0]) && (part[1] <  whole[1])) { return [[whole[0], part[0] - 1], [part[1] + 1, whole[1]]]; }
    if ((part[0] === whole[0]) && (part[1] <  whole[1])) { return [[part[1] + 1, whole[1]]]; }
    if ((part[0] >  whole[0]) && (part[1] === whole[1])) { return [[whole[0], part[0] - 1]]; }
  }

  subtractRanges(wholes, parts) {
    wholes = this.reduce(wholes);
    parts = this.reduce(parts);

    parts.forEach(part => {
      let output = [];
      wholes.forEach(whole => {
        return output = output.concat(this.subtractRange(whole, part));
      });
      return wholes = this.reduce(output);
    });
    return wholes;
  }

  selfTest() {
    return {
      length1:                 this.length([[1,1]]) === 1,
      length2:                 this.length([[1,2]]) === 2,
      serialize:               this.serialize([[1,2], [4,5]]) === "1-2,4-5",
      parse:           isEqual(this.parse("1-2,4-5"),                 [[1,2],[4,5]]),
      reduceSimple:    isEqual(this.reduce([[1,1]]), [[1,1]]),
      reduceMerge:     isEqual(this.reduce([[1,2],[3,4]]),            [[1,4]]),
      reduceEmpty:     isEqual(this.reduce([]), []),
      subtractWhole:   isEqual(this.subtractRange([1,1], [1,1]),      []),
      subtractNone:    isEqual(this.subtractRange([1,1], [2,2]),      [[1,1]]),
      subtractLeft:    isEqual(this.subtractRange([1,2], [1,1]),      [[2,2]]),
      subtractRight:   isEqual(this.subtractRange([1,2], [2,2]),      [[1,1]]),
      subtractMiddle:  isEqual(this.subtractRange([1,3], [2,2]),      [[1,1], [3,3]]),
      overlapsNone:            this.overlaps([1,2], [3,4]) === false,
      overlapsPart:            this.overlaps([1,2], [2,3]) === true,
      overlapsWhole:           this.overlaps([1,2], [1,2]) === true,
      subtractRanges1: isEqual(this.subtractRanges([[1,1]], [[1,1]]), []),
      subtractRanges2: isEqual(this.subtractRanges([[1,2]], [[1,1]]), [[2,2]]),
      subtractRanges3: isEqual(this.subtractRanges([[1,2], [4,6]], [[1,1], [5,5]]), [[2,2], [4,4], [6,6]]),
      subtractRanges4: isEqual(this.subtractRanges([[1,2], [4,8]], [[5,6], [7,8]]), [[1,2], [4,4]])
    };
  }

  hardTest() {
    return {subtractRanges5: isEqual(this.subtractRanges)};
  }
};
