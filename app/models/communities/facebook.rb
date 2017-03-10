class Communities::Facebook < Communities::Base
  set_community_type :facebook
  set_custom_fields :facebook_group_id, :facebook_user_id, :facebook_access_token

  validate :has_facebook_info

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

  def has_facebook_info
    errors.add(:facebook_access_token, "Must have an access_token") unless facebook_access_token.present?
    errors.add(:facebook_user_id, "Must have a user id") unless facebook_user_id.present?
  end

  def fetch_members
    HTTParty.get("https://graph.facebook.com/v2.8/#{facebook_group_id}/members?access_token=#{facebook_access_token}")
  end
end
