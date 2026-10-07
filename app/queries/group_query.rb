class GroupQuery
  def self.start
    Group.includes(:subscription, :creator, :parent)
  end

  def self.visible_to(user: LoggedOutUser.new, chain: start, show_public: false)
    return chain.none if user.deactivated_at.present?

    guest_group_ids = Topic.where(id: user.guest_topic_ids).pluck(:group_id).compact
    # Guests may see a thread's group context, but only actual parent members
    # inherit subgroup visibility. Do not mutate the user's cached memberships.
    group_ids = user.group_ids
    context_group_ids = group_ids | guest_group_ids
    chain.kept.
      where("#{'groups.is_visible_to_public = true OR ' if show_public}
            groups.id in (:context_group_ids) OR
            (groups.parent_id in (:group_ids) AND groups.is_visible_to_parent_members = TRUE)", group_ids: group_ids, context_group_ids: context_group_ids)
  end
end
