class PollCommunityService
  def self.assign_communities_for(poll)
    poll.communities_attributes = if poll.group
      [{ community_type: :loomio_group, custom_fields: { group_key: poll.group.key } }]
    elsif poll.participant_emails
      [{ community_type: :email, custom_fields: { emails: poll.participant_emails } }]
    else
      []
    end
  end
end
