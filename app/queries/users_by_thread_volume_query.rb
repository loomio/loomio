class UsersByThreadVolumeQuery
  def self.email(discussion)
    volume_and_discussion(:email, discussion)
  end

  def self.normal(discussion)
    volume_and_discussion(:normal, discussion)
  end

  def self.mute(discussion)
    volume_and_discussion(:mute, discussion)
  end

  private
  def self.volume_and_discussion(volume, discussion)
    User.
      active.
      joins("LEFT OUTER JOIN discussion_readers dr ON (dr.user_id = users.id AND dr.discussion_id = #{discussion.id})").
      joins("LEFT OUTER JOIN memberships m ON (m.user_id = users.id AND m.group_id = #{discussion.group_id})").
      where('dr.volume = :volume OR (dr.volume IS NULL AND m.volume = :volume)', { volume: DiscussionReader.volumes[volume] })
  end
end
