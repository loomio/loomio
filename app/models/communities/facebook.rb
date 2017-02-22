class Communities::Slack < Communities::Base
  set_custom_fields :facebook_group_id, :facebook_access_token

  def includes?(user)
    participants.map(&:token).include? user.participation_token
  end

  def participants
    @participants ||= Array(fetch_participants.dig('data')).map do |participant|
      Visitor.new(
        name:  participant['name'],
        participation_token: participant['id']
      )
    end
  end

  private

  def fetch_participants
    HTTParty.get("https://graph.facebook.com/v2.8/#{facebook_group_id}/members?access_token=#{facebook_access_token}")
  end
end
