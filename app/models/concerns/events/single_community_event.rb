module Events::SingleCommunityEvent
  def community
    @community ||= Communities::Base.find(custom_fields['community_id'])
  end

  private

  # only notify the community specified in the custom fields of this event
  def communities
    Array(community)
  end
end
