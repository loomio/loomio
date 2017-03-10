class Communities::Slack < Communities::Base
  set_custom_fields :slack_team_id, :slack_user_id, :slack_access_token
  set_community_type :slack
  validate :has_slack_info

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

  def has_slack_info
    errors.add(:slack_access_token, "Must have an access token") unless slack_access_token.present?
    errors.add(:slack_team_id, "Must have an team id") unless slack_team_id.present?
    errors.add(:slack_user_id, "Must have a user id") unless slack_user_id.present?
  end

  def fetch_members
    HTTParty.get("https://slack.com/api/users.list?token=#{slack_access_token}")
  end
end
