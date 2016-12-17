class Communities::Slack < Communities::Base
  set_custom_fields :slack_team_name, :slack_access_token

  def includes?(user)
    participants.map(&:token).include? user.participation_token
  end

  def participants
    @participants ||= Array(fetch_participants.dig('members')).map do |participant|
      Visitor.new(
        name:  participant.dig('profile', 'real_name'),
        email: participant['email'],
        participation_token: participant['id']
      )
    end
  end

  private

  def fetch_participants
    HTTParty.get("https://slack.com/api/users.list?token=#{slack_access_token}")
  end
end
