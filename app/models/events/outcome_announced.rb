class Events::OutcomeAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(outcome, actor, user_ids, audience = nil)
    raise "we dont use this now"
    super outcome,
          user: actor,
          recipient_user_ids: user_ids,
          recipient_audience: audience
  end
end
