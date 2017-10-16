class DiscussionReader < ActiveRecord::Base
  include HasVolume

  belongs_to :user
  belongs_to :discussion

  delegate :update_importance, to: :discussion
  delegate :importance, to: :discussion

  define_counter_cache(:read_items_count) { |reader| reader.read_ranges.map(&:count).sum }

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

  def update_reader(volume: nil, participate: false, dismiss: false)
    set_volume!(volume, persist: false) if volume && (volume != :loud || user.email_on_participation?)
    dismiss!(persist: false)            if dismiss
    save!                               if changed?
  end

  def viewed!(ranges = [], persist: true)
    mark_as_read(ranges) if has_read?(ranges)
    assign_attributes(last_read_at: Time.now, read_items_count: compute_read_items_count)
    EventBus.broadcast('discussion_reader_viewed!', self)
    save if persist
  end

  def has_read?(ranges = [])
    read_ranges.include? ranges
  end

  def mark_as_read(ranges)
    self.read_ranges = read_ranges.merge!(ranges)
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

  def read_ranges
    RangeSet.parse(self.read_ranges_string)
  end

  def read_ranges=(ranges)
    self.read_ranges_string = RangeSet.new(ranges).to_s
  end

  def membership
    @membership ||= discussion.group.membership_for(user)
  end
end
