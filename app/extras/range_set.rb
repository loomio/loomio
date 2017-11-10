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
      to_ranges(haystack).any? { |b| b.include?(a) }
    end
  end

  def self.to_ranges(ranges)
    # ranges is supposed to be an array of ranges.
    # but it's useful to support
    # range set
    return []                        if ranges.nil?
    # single id
    return [ranges..ranges]          if ranges.is_a? Numeric
    # single range
    return [ranges]                  if ranges.is_a? Range
    # array of ids
    return ranges.map {|id| id..id } if ranges.is_a?(Array) && ranges.first.is_a?(Numeric)
    # serialized array of range pairs
    return parse(ranges)             if ranges.is_a? String
    # as well as a well formatted array of ranges
    ranges
  end

  def self.subtract_range(whole, part)
    # examples

    # read nothing
    return [[whole.first, whole.last]] if (part.first > whole.last) || (part.last < whole.first)

    # read the whole thing
    # range [2,3]
    # read_range [2,3] or [1,4]
    # unread_ranges []
    return [] if (part.first <= whole.first) && (part.last >= whole.last)

    # read the middle
    # range [1,3]
    # read_range [2,2]
    # unread_ranges [[1,1],[2,2]]
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
  def self.subtract_ranges(whole_ranges, part_ranges)
    remaining = []
    whole_ranges.each do |whole_range|
      some_ranges.each do |part_range|
        subtract_range(whole_range, part_range).each do |remainder|
          remaining << remainder
        end
      end
    end
  end

  # for turning an array of likely sequential ids into ranges
  def self.ranges_from_list(ids)
    return [] if ids.empty?

    first_id = 1
    last_id = 1

    ranges = []
    ids.each do |id|
      if id == last_id + 1
        last_id = id
      else
        ranges << first_id..last_id
        first_id = id
      end
    end
    ranges << first_id..last_id
    ranges
  end

  def self.to_arrays(ranges)
    ranges.map {|r| [r.first, r.last] }
  end

  def self.parse(string)
    string.to_s.split(' ').map do |pair|
      Range.new *pair.split(',').map(&:to_i)
    end
  end

  def self.serialize(ranges)
    ranges.map{|r| [r.first,r.last].join(',')}.join(' ')
  end

  def self.reduce(ranges)
    # return [] if ranges.length == 0
    ranges = ranges.sort_by {|r| r.first }
    *reduced = ranges.shift
    ranges.each do |r|
      lastr = reduced[-1]
      if lastr.last >= r.first - 1
        reduced[-1] = lastr.first..[r.last, lastr.last].max
      else
        reduced.push(r)
      end
    end
    reduced
  end
end
