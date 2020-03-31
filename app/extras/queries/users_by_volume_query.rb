class Queries::UsersByVolumeQuery
  def self.normal_or_loud(model)
    users_by_volume(model, '>=', DiscussionReader.volumes[:normal])
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
      where('(m.id IS NOT NULL AND m.archived_at IS NULL) OR
             (dr.id IS NOT NULL and dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL) OR
             (s.id IS NOT NULL and s.revoked_at IS NULL AND s.inviter_id IS NOT NULL)').
      where("coalesce(s.volume, dr.volume, m.volume, 2) #{operator} :volume", volume: volume)
  end
end
