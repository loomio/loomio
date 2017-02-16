class Communities::LoomioUsers < Communities::Base
  set_community_type :loomio_users
  set_custom_fields  :loomio_user_ids, :group_key

  def to_group_community
    Communities::LoomioGroup.new(group_key: self.group_key)
  end

  def includes?(member)
    member.is_logged_in? && self.loomio_user_ids.include?(member.id)
  end

  def members
    @members ||= User.where(id: loomio_user_ids)
  end

  def notify!(event)
    # NOOP for now
  end
end
