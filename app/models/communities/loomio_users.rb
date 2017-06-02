class Communities::LoomioUsers < Communities::Base
  include Communities::Notify::InApp
  include Communities::Notify::Users
  set_community_type :loomio_users
  set_custom_fields  :loomio_user_ids, :slack_channel_id, :slack_channel_name

  alias :channel :slack_channel_id

  def to_group_community
    Communities::LoomioGroup.new(group_key: identifier)
  end

  def includes?(member)
    member.is_logged_in? && self.loomio_user_ids.include?(member.id)
  end
end
