class Communities::LoomioUsers < Communities::Base
  set_community_type :loomio_users
  set_custom_fields  :loomio_user_ids, :group_key

  def to_group_community
    Communities::LoomioGroup.new(group_key: self.group_key)
  end

  def includes?(participant)
    participant.is_logged_in? && self.loomio_user_ids.include?(participant.id)
  end

  def participants
    @participants ||= User.where(id: loomio_user_ids)
  end
end
