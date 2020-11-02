class Events::OutcomeCreated < Event
  include Events::Notify::ThirdParty
  include Events::Notify::Mentions
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::LiveUpdate

  def self.publish!(outcome:, user_ids: [])
    super(outcome,
          user: outcome.author,
          recipient_user_ids: user_ids)
  end
end
