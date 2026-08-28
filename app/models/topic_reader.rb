class TopicReader < ApplicationRecord
  include CustomCounterCache::Model
  include HasVolume

  extend HasTokens
  initialized_with_token :token

  belongs_to :user
  belongs_to :topic
  belongs_to :inviter, class_name: 'User'

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
        tr.volume_email = m&.volume_email || user.volume_email_default
        tr.volume_push = m&.volume_push || user.volume_push_default
      end
    else
      new(topic: topic)
    end
  end

  def update_reader(ranges: nil, volume_email: nil, volume_push: nil, participate: false, dismiss: false)
    viewed!(ranges, persist: false)     if ranges
    if (volume_email || volume_push) && (volume_email.nil? || volume_email.to_sym != :loud || user.email_on_participation?)
      set_volume!(
        email: volume_email || self.volume_email || computed_volume_email,
        push: volume_push || self.volume_push || computed_volume_push,
        persist: false
      )
    end
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

  def computed_volume_email
    if persisted?
      volume_email || membership&.volume_email || user.volume_email_default
    else
      membership&.volume_email || user.volume_email_default
    end
  end

  def computed_volume_push
    if persisted?
      volume_push || membership&.volume_push || user.volume_push_default
    else
      membership&.volume_push || user.volume_push_default
    end
  end

  def topic_reader_volume_email
    self[:volume_email]
  end

  def topic_reader_volume_push
    self[:volume_push]
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
    RangeSet.subtract_ranges(topic.ranges, read_ranges)
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
