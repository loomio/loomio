class GroupRelocator
  def self.perform!(group_map: {})
    deferred = {}
    group_map.each do |key, value|
      if move_group(key, value)
        # it worked!
      else
        deferred[key] = value
      end
    end

    deferred.each { |key, value| move_group(key) }

    Group.where(name: group_map.values, creator: User.helper_bot).pluck(:key)
  end

  def self.move_group(key, value)
    group  = Group.find_by(key: key)
    return unless group.subgroups.empty?

    parent = Group.find_or_create_by(name: value, creator: User.helper_bot)

    group.update(subscription: nil, parent: parent)
    group.reload.memberships.where.not(user_id: parent.member_ids).active.each do |membership|
      if membership.admin
        parent.add_admin!(membership.user)
      else
        parent.add_member!(membership.user)
      end
    end
    true
  end
end
