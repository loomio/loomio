class Topic < ApplicationRecord
  belongs_to :topicable, polymorphic: true
  belongs_to :group, class_name: 'Group', optional: true
  belongs_to :closer, foreign_key: 'closer_id', class_name: 'User', optional: true
  has_many :items, -> { includes(:user) }, class_name: 'Event', dependent: :destroy
  has_many :topic_readers, dependent: :destroy
  has_many :comments, through: :items, source: :eventable, source_type: 'Comment'

  def members
    User.active
        .joins("LEFT OUTER JOIN topic_readers tr ON tr.topic_id = #{id} AND tr.user_id = users.id")
        .joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{group_id || 0}")
        .where('(m.id IS NOT NULL AND m.revoked_at IS NULL) OR
                (tr.id IS NOT NULL AND tr.guest = TRUE AND tr.revoked_at IS NULL)')
  end

  def admins
    User.active
        .joins("LEFT OUTER JOIN topic_readers tr ON tr.topic_id = #{id} AND tr.user_id = users.id")
        .joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{group_id || 0}")
        .where('(m.admin = TRUE AND m.id IS NOT NULL AND m.revoked_at IS NULL) OR
                (tr.admin = TRUE AND tr.id IS NOT NULL AND tr.revoked_at IS NULL)')
  end

  def guests
    User.active
        .joins("LEFT OUTER JOIN topic_readers tr ON tr.topic_id = #{id} AND tr.user_id = users.id")
        .joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{group_id || 0}")
        .where('(m.id IS NULL OR m.revoked_at IS NOT NULL) AND (tr.id IS NOT NULL AND tr.guest = TRUE AND tr.revoked_at IS NULL)')
  end

  def guest_ids
    guests.pluck(:id)
  end

  def add_guest!(user, inviter)
    if (tr = topic_readers.find_by(user: user))
      tr.update(guest: true, inviter: inviter)
    else
      topic_readers.create!(user: user, inviter: inviter, guest: true, volume: TopicReader.volumes[:normal])
    end
  end

  def add_admin!(user, inviter)
    if (tr = topic_readers.find_by(user: user))
      tr.update(inviter: inviter, admin: true)
    else
      topic_readers.create!(user: user, inviter: inviter, admin: true, volume: TopicReader.volumes[:normal])
    end
  end

  def update_sequence_info!
    sequence_ids = items.order(:sequence_id).pluck(:sequence_id).compact
    new_ranges = RangeSet.serialize RangeSet.reduce RangeSet.ranges_from_list(sequence_ids)
    update_columns(
      items_count: sequence_ids.count,
      ranges_string: new_ranges,
      last_activity_at: topicable.find_last_activity_at
    )
  end

  def ranges
    RangeSet.parse(ranges_string)
  end

  def first_sequence_id
    Array(ranges.first).first.to_i
  end

  def last_sequence_id
    Array(ranges.last).last.to_i
  end

  def drop_sequence_id_sequence
    SequenceService.drop_seq!('topic_sequence_id', id)
  end
end
