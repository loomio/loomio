class GroupQuery
  def self.start
    Group.includes(:subscription, :creator, :parent, :default_group_cover)
  end

  def self.visible_to(user: LoggedOutUser.new, chain: start, show_public: false)
    guest_discussion_group_ids = Discussion.where(id: user.guest_discussion_ids).pluck(:group_id)
    group_ids = user.group_ids.concat(guest_discussion_group_ids)
    chain.published.
      where("#{'is_visible_to_public = true OR ' if show_public}
            groups.id in (:group_ids) OR
            (parent_id in (:group_ids) AND is_visible_to_parent_members = TRUE)", group_ids: group_ids)
  end
end
