class Communities::LoomioUsers < Communities::Base
  include Communities::NotifyLoomioGroup
  set_community_type :loomio_users
  set_custom_fields  :loomio_user_ids

  def to_group_community
    Communities::LoomioGroup.new(group_key: identifier)
  end

  def includes?(member)
    member.is_logged_in? && self.loomio_user_ids.include?(member.id)
  end
end
