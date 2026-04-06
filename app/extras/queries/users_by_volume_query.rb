class Queries::UsersByVolumeQuery
  def self.normal_or_loud(topic)
    users_by_volume(topic, '>=', TopicReader.volumes[:normal])
  end

  def self.email_notifications(topic)
    normal_or_loud(topic)
  end

  def self.app_notifications(topic)
    users_by_volume(topic, '>=', TopicReader.volumes[:quiet])
  end

  %w(mute quiet normal loud).map(&:to_sym).each do |volume|
    define_singleton_method volume, ->(topic) {
      users_by_volume(topic, '=', TopicReader.volumes[volume])
    }
  end

  private

  def self.users_by_volume(topic, operator, volume)
    return User.none if topic.nil?
    User.active.distinct.
      joins("LEFT OUTER JOIN topic_readers tr ON tr.topic_id = #{topic.id} AND tr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{topic.group_id || 0}").
      where('(m.id IS NOT NULL AND m.revoked_at IS NULL) OR
             (tr.id IS NOT NULL AND tr.guest = TRUE AND tr.revoked_at IS NULL) OR
             (m.id IS NULL and tr.id IS NULL)').
      where("coalesce(tr.volume, m.volume, 2) #{operator} :volume", volume: volume)
  end
end
