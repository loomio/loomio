class Queries::UsersByVolumeQuery
  def self.normal_or_loud(topic)
    users_by_volume(topic, TopicReader.volume_emails.values_at(:normal, :loud), channel: :email)
  end

  def self.email_notifications(topic)
    normal_or_loud(topic)
  end

  def self.app_notifications(topic)
    email_users = users_by_volume(topic, TopicReader.volume_emails.values_at(:quiet, :normal, :loud), channel: :email)
    push_users = users_by_volume(topic, TopicReader.volume_pushes.values_at(:quiet, :normal, :loud), channel: :push)
    User.where(id: email_users.select(:id)).or(User.where(id: push_users.select(:id)))
  end

  %w[mute quiet normal loud].map(&:to_sym).each do |level|
    define_singleton_method level, ->(topic) {
      users_by_volume(topic, [ TopicReader.volume_emails[level] ], channel: :email)
    }
  end

  private

  # Volume modes are named delivery policies rather than a total ordering, so
  # callers identify the exact modes that qualify for a given kind of delivery.
  def self.users_by_volume(topic, levels, channel:)
    return User.none if topic.nil?
    volume_condition =
      case channel
      when :email then 'coalesce(tr.volume_email, m.volume_email, 2) IN (:levels)'
      when :push then 'coalesce(tr.volume_push, m.volume_push, 0) IN (:levels)'
      else raise ArgumentError, "Unknown volume channel: #{channel}"
      end

    scope = User.active.distinct.
      joins("LEFT OUTER JOIN topic_readers tr ON tr.topic_id = #{topic.id} AND tr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{topic.group_id || 0}").
      where('(m.id IS NOT NULL AND m.revoked_at IS NULL) OR
             (tr.id IS NOT NULL AND tr.guest = TRUE AND tr.revoked_at IS NULL) OR
             (m.id IS NULL and tr.id IS NULL)').
      where(volume_condition, levels: levels)
  end
end
