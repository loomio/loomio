class GroupQuery
  def self.start
    Group.includes(:subscription, :creator)
  end

  def self.visible_to(user: , chain: start, show_public: false)
    ids = user.group_ids

    Group.includes(:subscription, :creator)
         .published.where(id: ids)
         .or(Group.published
                  .where('parent_id in (:ids)', ids: ids)
                  .where('is_visible_to_parent_members = true or is_visible_to_public = true'))
  end
end
