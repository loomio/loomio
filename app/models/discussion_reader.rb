class DiscussionReader < ActiveRecord::Base
  include HasVolume

  belongs_to :user
  belongs_to :discussion

  delegate :update_importance, to: :discussion
  delegate :importance, to: :discussion

  define_counter_cache(:read_items_count) { |reader| reader.compute_read_items_count }

  def self.for(user:, discussion:)
    if user&.is_logged_in?
      find_or_create_by(user: user, discussion: discussion)
    else
      new(discussion: discussion)
    end
  end

  def self.for_model(model, actor = nil)
    self.for(user: actor || model.author, discussion: model.discussion)
  end

  def update_reader(read_at: nil, volume: nil, participate: false, dismiss: false)
    viewed!([], persist: false)         if read_at
    set_volume!(volume, persist: false) if volume && (volume != :loud || user.email_on_participation?)
    dismiss!(persist: false)            if dismiss
    save!                               if changed?
  end

  def viewed!(sequence_ids, persist: true)
    return if has_read?(sequence_ids)
    mark_as_read(sequence_ids)
    assign_attributes(last_read_at: Time.now, read_items_count: compute_read_items_count)
    EventBus.broadcast('discussion_reader_viewed!', self)
    save if persist
  end

  def has_read?(sequence_ids)
    Array(sequence_ids).all? do |id|
      parse_read_ranges.any? { |range| range.include?(id) }
    end
  end

  def mark_as_read(sequence_ids)
    ranges = Array(sequence_ids).uniq.map{|id| Range.new(id,id) } + parse_read_ranges
    reduced = reduce_ranges reduce_ranges(ranges) # no i'm not sure why I need it twice..
    assign_attributes(read_sequence_id_ranges: serialize_read_ranges(reduced))
  end

  def dismiss!(persist: true)
    self.dismissed_at = Time.zone.now
    EventBus.broadcast('discussion_reader_dismissed!', self)
    save if persist
  end

  def volume
    if persisted?
      super || membership&.volume || 'normal'
    else
      membership.volume
    end
  end

  def discussion_reader_volume
    # Crazy James says: necessary in order to get a string back from the volume enum, rather than an integer
    self.class.volumes.invert[self[:volume]]
  end

  private
  def serialize_read_ranges(ranges)
    # could merge adjancent ranges in the future
    self.read_sequence_id_ranges = ranges.sort_by{|r| r.first}.map{|r| [r.first,r.last].join(',')}.join(' ')
  end

  def parse_read_ranges
    self.read_sequence_id_ranges.to_s.split(' ').map do |pair|
      Range.new *pair.split(',').map(&:to_i)
    end
  end

  def compute_read_items_count
    parse_read_ranges.map(&:count).sum
  end

  def can_merge?(a, b)
    a.include?(b.first - 1) || a.include?(b.last + 1)
  end

  def merge(ranges)
    sorted = ranges.map{|r| [r.first, r.last] }.flatten.sort
    Range.new(sorted.first, sorted.last)
  end

  def reduce_ranges(ranges)
    ranges.map do |a|
     mergable = ranges.select { |b| can_merge?(a,b) }
     if mergable.any?
       merge([mergable, a].flatten)
     else
       a
     end
   end.uniq
  end

  def membership
    @membership ||= discussion.group.membership_for(user)
  end
end
