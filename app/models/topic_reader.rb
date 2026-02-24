class TopicReader < ApplicationRecord
  include CustomCounterCache::Model
  include HasVolume

  extend HasTokens
  initialized_with_token :token

  belongs_to :user
  belongs_to :topic
  belongs_to :inviter, class_name: 'User'

  scope :dangling, lambda {
    joins('left join topics on topics.id = topic_id left join users on users.id = user_id')
      .where('topics.id is null or users.id is null')
  }

  scope :active, -> { where('topic_readers.revoked_at IS NULL') }

  scope :guests, -> { active.where('topic_readers.guest': true) }
  scope :admins, -> { active.where('topic_readers.admin': true) }

  scope :redeemable, -> { guests.where('topic_readers.accepted_at IS NULL') }

  scope :redeemable_by, lambda { |user_id|
    redeemable.joins(:user).where('user_id = ? OR users.email_verified = false', user_id)
  }

  after_save    :update_topic_counters
  after_destroy :update_topic_counters

  def self.for(user:, topic:)
    if user&.is_logged_in?
      find_or_initialize_by(user_id: user.id, topic_id: topic.id) do |tr|
        m = topic.group_id && user.memberships.find_by(group_id: topic.group_id)
        tr.volume = (m && m.volume) || 'normal'
      end
    else
      new(topic: topic)
    end
  end

  def update_reader(ranges: nil, volume: nil, participate: false, dismiss: false)
    viewed!(ranges, persist: false)     if ranges
    set_volume!(volume, persist: false) if volume && (volume != :loud || user.email_on_participation?)
    dismiss!(persist: false)            if dismiss
    save!                               if changed?
    self
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

  def recall!(persist: true)
    self.dismissed_at = nil
    save if persist
  end

  def computed_volume
    if persisted?
      volume || membership&.volume || 'normal'
    else
      membership.volume
    end
  end

  def topic_reader_volume
    self[:volume]
  end

  def topic_reader_user_id
    user_id
  end

  def read_ranges
    RangeSet.parse(read_ranges_string)
  end

  def read_ranges=(ranges)
    ranges = RangeSet.reduce(ranges)
    self.read_ranges_string = RangeSet.serialize(ranges)
  end

  def first_unread_sequence_id
    Array(unread_ranges.first).first.to_i
  end

  def unread_ranges
    topicable = topic&.topicable
    topic_ranges = topic&.ranges || []
    RangeSet.subtract_ranges(topic_ranges, read_ranges)
  end

  def read_ranges_string
    self[:read_ranges_string] ||= if last_read_sequence_id == 0
                                    ''
                                  else
                                    first_seq = topic&.first_sequence_id || 1
                                    "#{[first_seq, 1].max}-#{last_read_sequence_id}"
                                  end
  end

  def read_items_count
    RangeSet.length(read_ranges)
  end

  def unread_items_count
    RangeSet.length(unread_ranges)
  end

  private

  def membership
    group = topic&.topicable&.respond_to?(:group) ? topic.topicable.group : nil
    @membership ||= group&.membership_for(user)
  end

  def update_topic_counters
    topic.update_seen_by_count
    topic.update_members_count
  end
end
