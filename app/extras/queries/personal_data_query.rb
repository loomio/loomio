class Queries::PersonalDataQuery
  def self.visits(user)
    Visit.where(user_id: user.id)
  end

  def self.ahoy_events(user)
    Ahoy::Event.where(user_id: user.id)
  end

  def self.ahoy_messages(user)
    Ahoy::Message.where(user_id: user.id)
  end

  def self.comments(user)
    Comment.where(user_id: user.id)
  end

  def self.discussion_readers(user)
    DiscussionReader.where(user_id: user.id)
  end

  def self.discussions(user)
    Discussion.where(author_id: user.id)
  end

  def self.documents(user)
    Document.where(author_id: user.id)
  end

  def self.events(user)
    Event.where(user_id: user.id)
  end

  def self.group_identities(user)
    GroupIdentity.where(identity_id: user.identity_ids)
  end

  def self.groups(user)
    Group.where(creator_id: user.id)
  end

  def self.group_visits(user)
    GroupVisit.where(user_id: user.id)
  end

  def self.login_tokens(user)
    LoginToken.where(user_id: user.id)
  end

  def self.membership_requests(user)
    MembershipRequest.where(requestor_id: user.id).or(MembershipRequest.where(responder_id: user.id))
  end

  def self.memberships(user)
    Membership.where(user_id: user.id)
  end

  def self.notifications(user)
    Notification.where(user_id: user.id).
      or(Notification.where(actor_id: user.id))
  end

  def self.identities(user)
    Identities::Base.where(user_id: user.id).
      or(Identities::Base.where(email: user.email))
  end

  def self.organisation_visits(user)
    OrganisationVisit.where(user_id: user.id)
  end

  def self.outcomes(user)
    Outcome.where(author_id: user.id)
  end

  def self.poll_unsubscriptions(user)
    PollUnsubscription.where(user_id: user.id)
  end

  def self.polls(user)
    Poll.where(author_id: user.id)
  end

  def self.reactions(user)
    Reaction.where(user_id: user.id)
  end

  def self.stances(user)
    Stance.where(participant_id: user.id)
  end

  def self.deactivation_responses(user)
    UserDeactivationResponse.where(user_id: user.id)
  end

  def self.users(user)
    User.where(email: user.email)
  end

  def self.versions(user)
    PaperTrail::Version.where(whodunnit: user.id)
  end
end
