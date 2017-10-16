class RangeSet
  def initialize(something)
    @ranges = klass.to_ranges(something)
  end

  def merge(something)
    @ranges = klass.reduce(@ranges.concat(klass.to_ranges(ranges)))
    self
  end

  def includes?(something)
    klass.includes?(@ranges, something)
  end

  def to_s
    self.class.serialize(@ranges)
  end

  def klass
    self.class
  end

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
    return ranges.ranges             if ranges.is_a? RangeSet
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

  def self.parse(string)
    string.to_s.split(' ').map do |pair|
      Range.new *pair.split(',').map(&:to_i)
    end
  end

  def self.serialize(ranges)
    merge(ranges).map{|r| [r.first,r.last].join(',')}.join(' ')
  end

  def self.reduce(ranges)
    return [] if ranges.is_empty?
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
