class DiscussionReader < ActiveRecord::Base
  include HasVolume

  belongs_to :user
  belongs_to :discussion

  delegate :update_importance, to: :discussion
  delegate :importance, to: :discussion

  update_counter_cache :discussion, :seen_by_count

  def self.for(user:, discussion:)
    if user&.is_logged_in?
      begin
        find_or_create_by(user: user, discussion: discussion)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    else
      new(discussion: discussion)
    end
  end

  def self.for_model(model, actor = nil)
    self.for(user: actor || model.author, discussion: model.discussion)
  end

  def update_reader(ranges: nil, volume: nil, participate: false, dismiss: false)
    viewed!(ranges, persist: false)     if ranges
    set_volume!(volume, persist: false) if volume && (volume != :loud || user.email_on_participation?)
    dismiss!(persist: false)            if dismiss
    save!                               if changed?
  end

  def viewed!(ranges = [], persist: true)
    mark_as_read(ranges) unless has_read?(ranges)
    assign_attributes(last_read_at: Time.now)
    save if persist
  end

  def has_read?(ranges = [])
    RangeSet.includes?(read_ranges, ranges)
  end

  def mark_as_read(ranges)
    ranges = RangeSet.to_ranges(ranges)
    return if ranges.empty?
    self.read_ranges = read_ranges.concat(ranges)
  end

  def dismiss!(persist: true)
    self.dismissed_at = Time.zone.now
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

  # because items can be deleted, we need to count the number of items in each range against the db
  def calculate_read_items_count
    read_ranges.sum {|r| discussion.items.where(sequence_id: r).count }
  end

  def unread_ranges
    RangeSet.subtract_ranges(ranges, read_ranges)
  end

  def first_unread_sequence_id

    read_ranges.detect{|read_range| ranges.any?{|range| range.contains? read_range.last + 1}}

    (discussion.ranges.first&.last || 0) + 1
  end

  private

  def read_ranges
    RangeSet.parse(self.read_ranges_string)
  end

  def read_ranges=(ranges)
    ranges = RangeSet.reduce(ranges)
    self.read_ranges_string = RangeSet.serialize(ranges)
    self.read_items_count = calculate_read_items_count
  end

  def membership
    @membership ||= discussion.group.membership_for(user)
  end
end
