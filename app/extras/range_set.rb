class RangeSet
  # def initialize(ranges)
  #   @ranges = klass.to_ranges(ranges)
  # end
  #
  # def merge(ranges)
  #   @ranges = klass.reduce(@ranges.concat(klass.to_ranges(ranges)))
  #   self
  # end
  #
  # def includes?(ranges)
  #   klass.includes?(@ranges, ranges)
  # end
  #
  # def to_s
  #   self.class.serialize(@ranges)
  # end
  #
  # def klass
  #   self.class
  # end
  #
  # def empty?
  #   @ranges.empty?
  # end

  # class methods
  def self.includes?(haystack, needle)
    to_ranges(needle).all? do |a|
      to_ranges(haystack).any? { |b| overlaps?(a, b) }
    end
  end

  # do 2 ranges overlap?
  def self.overlaps?(a,b)
    if a.first > b.first
      new_a = b
      b = a
      a = new_a
    end
    # a.first is less than or equal to b.first
    a.first == b.first || a.last >= b.first
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

    first_id = 1
    last_id = 1

    ranges = []
    ids.each do |id|
      if id == last_id + 1
        last_id = id
      else
        ranges << [first_id,last_id]
        first_id = id
      end
    end
    ranges << [first_id,last_id]
    ranges
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
