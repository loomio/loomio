class Communities::Slack < Communities::Base
  set_custom_fields :facebook_group_id, :facebook_access_token

  def includes?(member)
    members.map(&:token).include? member.participation_token
  end

  def members
    @members ||= Array(fetch_members.dig('data')).map do |member|
      Visitor.new(
        name:  member['name'],
        participation_token: member['id']
      )
    end
  end

  def notify!(event)
    # post in the facebook group about the event if appropriate
  end

  private

  def fetch_members
    HTTParty.get("https://graph.facebook.com/v2.8/#{facebook_group_id}/members?access_token=#{facebook_access_token}")
  end
end
