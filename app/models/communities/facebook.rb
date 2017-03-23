class Communities::Facebook < Communities::Base
  set_community_type :facebook
  set_custom_fields :facebook_group_name

  def includes?(participant)
    participant.identities.where(identity_type: :facebook).any? { |i| i.is_member_of?(self) }
  end

  def members
    []
  end

  def notify!(event)
    # post in the facebook group about the event if appropriate
  end

end
