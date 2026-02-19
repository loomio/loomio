class Queries::UsersByVolumeQuery
  def self.normal_or_loud(model)
    users_by_volume(model, '>=', TopicReader.volumes[:normal])
  end

  def self.email_notifications(model)
    normal_or_loud(model)
  end

  def self.app_notifications(model)
    users_by_volume(model, '>=', TopicReader.volumes[:quiet])
  end

  %w(mute quiet normal loud).map(&:to_sym).each do |volume|
    define_singleton_method volume, ->(model) {
      users_by_volume(model, '=', TopicReader.volumes[volume])
    }
  end

  private

  def self.resolve_topic_id(model)
    if model.respond_to?(:topic) && model.topic
      model.topic.id
    elsif model.respond_to?(:discussion) && model.discussion&.topic
      model.discussion.topic.id
    else
      0
    end
  end

  def self.users_by_volume(model, operator, volume)
    return User.none if model.nil?
    topic_id = resolve_topic_id(model)
    User.active.distinct.
      joins("LEFT OUTER JOIN topic_readers tr ON tr.topic_id = #{topic_id} AND tr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{model.group_id || 0}").
      where('(m.id IS NOT NULL AND m.revoked_at IS NULL) OR
             (tr.id IS NOT NULL AND tr.guest = TRUE AND tr.revoked_at IS NULL) OR
             (m.id IS NULL and tr.id IS NULL)').
      where("coalesce(tr.volume, m.volume, 2) #{operator} :volume", volume: volume)
  end
end
