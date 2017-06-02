class VisitorsBatchCreateJob < ActiveJob::Base
  def perform(poll, emails, actor)
    emails.take(Rails.application.secrets.max_pending_emails).each do |email|
      VisitorService.create(
        visitor: Visitor.new(community: poll.community_of_type(:email), email: email),
        actor: actor,
        poll: poll
      ) unless email == actor.email
    end
  end
end
