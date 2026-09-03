class GroupQuery
  def self.start
    Group.includes(:subscription, :creator, :parent)
  end

  def self.visible_to(user: LoggedOutUser.new, chain: start, show_public: false)
    return chain.none if user.deactivated_at.present?

    guest_group_ids = Topic.where(id: user.guest_topic_ids).pluck(:group_id).compact
    group_ids = user.group_ids.concat(guest_group_ids)
    chain.published.
      where("#{'groups.is_visible_to_public = true OR ' if show_public}
            groups.id in (:group_ids) OR
            (groups.parent_id in (:group_ids) AND groups.is_visible_to_parent_members = TRUE)", group_ids: group_ids)
  end
end
