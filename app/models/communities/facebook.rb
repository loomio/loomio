class Communities::Facebook < Communities::Base
  set_community_type :facebook
  set_custom_fields :facebook_group_id, :facebook_group_name

  def includes?(member)
    members.map(&:token).include? member.participation_token
  end

  def members
    []
    # @members ||= Array(fetch_members.dig('data')).map do |member|
    #   Visitor.new(
    #     name:  member['name'],
    #     participation_token: member['id']
    #   )
    # end
  end

  def notify!(event)
    # post in the facebook group about the event if appropriate
  end

end
