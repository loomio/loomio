class VisitorsBatchCreateJob < ActiveJob::Base
  def perform(emails, poll_id, actor_id)
    return unless poll  = Poll.find_by(id: poll_id)
    return unless actor = User.active.find_by(id: actor_id)

    Array(emails).compact.take(Rails.application.secrets.max_pending_emails).each do |email|
      VisitorService.create(
        visitor: Visitor.new(community: poll.community_of_type(:email), email: email),
        actor: actor,
        poll: poll
      ) unless email == actor.email
    end
  end
end
