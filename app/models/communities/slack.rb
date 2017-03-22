class Communities::Slack < Communities::Base
  set_custom_fields :slack_channel_name
  set_community_type :slack

  def includes?(member)
    members.map(&:token).include? member.participation_token
  end

  def members
    []
    # @members ||= Array(fetch_members.dig('members')).map do |participant|
    #   Visitor.new(
    #     name:  participant.dig('profile', 'real_name'),
    #     email: participant['email'],
    #     participation_token: participant['id']
    #   )
    # end
  end

  def notify!(event)
    # send the event to a slack channel
  end

end
