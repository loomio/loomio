class Communities::Slack < Communities::Base
  set_custom_fields :slack_team_name, :slack_access_token

  def includes?(member)
    members.map(&:token).include? member.participation_token
  end

  def members
    @members ||= Array(fetch_members.dig('members')).map do |participant|
      Visitor.new(
        name:  participant.dig('profile', 'real_name'),
        email: participant['email'],
        participation_token: participant['id']
      )
    end
  end

  def notify!(event)
    # send the event to a slack channel
  end

  private

  def fetch_members
    HTTParty.get("https://slack.com/api/users.list?token=#{slack_access_token}")
  end
end
