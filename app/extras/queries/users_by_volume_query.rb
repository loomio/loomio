class Queries::UsersByVolumeQuery
  def self.normal_or_loud(model)
    users_by_volume(model, '>=', DiscussionReader.volumes[:normal])
  end

  def self.email_notifications(model)
    normal_or_loud(model)
  end

  def self.app_notifications(model)
    users_by_volume(model, '>=', DiscussionReader.volumes[:quiet])
  end

  %w(mute quiet normal loud).map(&:to_sym).each do |volume|
    define_singleton_method volume, ->(model) {
      users_by_volume(model, '=', DiscussionReader.volumes[volume])
    }
  end

  private

  def self.users_by_volume(model, operator, volume)
    return User.none if model.nil?
    User.active.distinct.
      joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = #{model.discussion_id || 0} AND dr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{model.group_id || 0}").
      joins("LEFT OUTER JOIN stances s ON s.participant_id = users.id AND s.poll_id = #{model.poll_id || 0} AND s.latest = TRUE").
      where('(m.id IS NOT NULL AND m.revoked_at IS NULL) OR
             (dr.id IS NOT NULL AND dr.guest = TRUE AND dr.revoked_at IS NULL) OR
             (s.id IS NOT NULL AND s.guest = TRUE AND s.revoked_at IS NULL) OR
             (m.id IS NULL and dr.id IS NULL and s.id IS NULL)').
      where("coalesce(s.volume, dr.volume, m.volume, 2) #{operator} :volume", volume: volume)
  end
end
