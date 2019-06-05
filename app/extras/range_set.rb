class RangeSet
  def self.includes?(haystack, needle)
    to_ranges(needle).all? do |a|
      to_ranges(haystack).any? { |b| range_includes?(b, a) }
    end
  end

  def self.range_includes?(a, b)
    return false if (a.length == 0 || b.length == 0)
    a[0] <= b[0] && a[1] >= b[1]
  end

  def self.length(ranges)
    ranges.map {|range| range[1] - range[0] + 1}.sum
  end

  # do 2 ranges overlap?
  def self.overlaps?(a,b)
    sorted = [a,b].sort_by{|r| r[0] }
    sorted[0][1] >= sorted[1][0]
  end

  def self.to_ranges(ranges)
    # ranges is supposed to be an array of ranges.
    # but it's useful to support
    # range set
    return []                            if ranges.nil?
    # single id
    return [[ranges, ranges]]            if ranges.is_a? Numeric
    # single range
    return [[ranges.first, ranges.last]] if ranges.is_a? Range
    # array of ids
    return ranges.map {|id| [id,id] }    if ranges.is_a?(Array) && ranges.first.is_a?(Numeric)
    # serialized array of range pairs
    return parse(ranges)                 if ranges.is_a? String
    # as well as a well formatted array of ranges
    ranges
  end

  def self.intersect_ranges(ranges1, ranges2)
    set1 = ranges_to_list(ranges1)
    set2 = ranges_to_list(ranges2)
    ranges_from_list(set1.select { |id| set2.include? id })
  end

  def self.ranges_to_list(ranges)
    ranges.map {|range| (range[0]..range[1]).to_a}.flatten
  end

  def self.subtract_range(whole, part)
    # examples
    # read nothing
    return [whole] if part.empty? || (part.first > whole.last) || (part.last < whole.first)

    # read the whole thing
    # range [2,3]
    # read_range [2,3] or [1,4]
    # unread_ranges []
    return [] if (part.first <= whole.first) && (part.last >= whole.last)

    # read the middle
    # range [1,3]
    # read_range [2,2]
    # unread_ranges [[1,1],[3,3]]
    return [[whole.first, part.first - 1], [part.last + 1, whole.last]] if (part.first > whole.first) && (part.last < whole.last)

    # read the first part
    # range      [1,3]
    # read_range [1,2]
    # unread_ranges [[3,3]]
    return [[part.last + 1, whole.last]]   if (part.first == whole.first) && (part.last < whole.last)

    # read the last part
    # range      [1,3]
    # read_range [2,3]
    # unread_ranges [[1,1]]
    # start of unread_range is either same as range.first or read_range.last
    return [[whole.first, part.first - 1]] if (part.first > whole.first) && (part.last == whole.last)
  end

  # all ranges: [[1,2]] , some ranges: [[1,1]]

  def self.subtract_ranges(wholes, parts)
    # take parts from wholes, returning wholes minus parts
    output = wholes
    parts.in_groups_of(1, false) do |part|
      output = subtract_ranges_old(output, part)
    end
    reduce output
  end

  def self.subtract_ranges_old(wholes, parts)
    output = wholes
    while (subtract_ranges_loop(output, parts) != output) do
      output = subtract_ranges_loop(output, parts)
    end
    reduce output
  end

  def self.subtract_ranges_loop(input, parts)
    output = []
    input.each do |whole|
      if parts.any?{|part| overlaps?(whole, part)}
        parts.select {|part| overlaps?(whole, part) }.each do |part|
          subtract_range(whole, part).each do |remainder|
            output << remainder
          end
        end
      else
        output << whole
      end
    end
    output
  end

  # for turning an array of likely to be sequential ids into ranges (eg: pluck -> ranges)
  def self.ranges_from_list(ids)
    return [] if ids.empty?
    ranges = []

    last_id = ids.first
    first_id = ids.first

    ids.each do |id|
      if id == last_id + 1
        last_id = id
      else
        ranges << [first_id,last_id]
        first_id = id
        last_id = id
      end
    end
    ranges << [first_id,last_id]
    reduce ranges
  end

  def self.parse(string)
    # ranges string format [[1,2], [4,5]] == 1-2,4-5
    string.to_s.split(',').map do |pair|
      pair.split('-').map(&:to_i)
    end
  end

  def self.serialize(ranges)
    ranges.map{|r| [r.first,r.last].join('-')}.join(',')
  end

  def self.reduce(ranges)
    return [] if ranges.length == 0
    ranges = ranges.sort_by {|r| r.first }
    reduced = [ranges.shift]
    ranges.each do |r|
      lastr = reduced[-1]
      if lastr.last >= r.first - 1
        reduced[-1] = [lastr.first,[r.last, lastr.last].max]
      else
        reduced.push(r)
      end
    end
    reduced
  end
end
