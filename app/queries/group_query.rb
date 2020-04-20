class GroupQuery
  def self.start
    Group.includes(:subscription, :creator)
  end

  def self.visible_to(user: , chain: start, show_public: false)
    chain.published
    .joins("LEFT OUTER JOIN memberships m on m.group_id = groups.id AND m.user_id = #{user.id || 0}")
    .joins("LEFT OUTER JOIN memberships pm on pm.group_id = groups.parent_id AND pm.user_id = #{user.id || 0}")
    .where("#{'groups.is_visible_to_public = true OR ' if show_public}
            (m.id IS NOT NULL AND memberships.archived_at is not null) OR
            (pm.id IS NOT NULL AND pm.is_visible_to_parent_members = true))")
  end
end
