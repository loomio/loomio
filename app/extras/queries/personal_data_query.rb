class Queries::PersonalDataQuery
  # possible whitelist for tables
  # {
  #   ahoy_events: [:visit_id, :user_id, :properties],
  #   ahoy_messages: [:to, :user_id],
  #   attachments: [:user_id, :filename],
  #   comments: [:body, :user_id], # body may contain your username
  #   discussion_readers: [:user_id],
  #   discussions: [:author_id, :title, :description],
  #   documents: [:author_id, :web_url, :thumb_url, :file_file_name, :title, :url],
  #   drafts: [:user_id, :payload],
  #   events: [:user_id, :discussion_id, :kind, :eventable_id, :eventable_type],
  #   group_visits: [:visit_id, :group_id, :user_id],
  #   groups: [:creator_id, :name, :country, :region, :city],
  #   invitations: [:recipient_email, :recipient_name, :inviter_id, :message],
  #   login_tokens: [:user_id],
  #   membership_request: [:name, :email, :introduction, :group_id, :requestor_id]
  # }
  #
  # # records associated to an identity, assoicated to your user account
  #   #
  # {
  #   group_identities: [:group_id, :identity_id, :custom_fields],
  # }

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
    GroupVisits.where(user_id: user.id)
  end

  def self.invitations(user)
    Invitation.where(recipient_email: user.email).
               or(Invitation.where(inviter_id: user.id)).
               or(Invitation.where(canceller_id: user.id))
  end

  def self.login_tokens(user)
    LoginToken.where(user_id: user.id)
  end

  def self.membership_requests(user)
    MembershipRequest.where(email: user.email).
      or(MembershipRequest.where(requestor_id: user.id)).
      or(MembershipRequest.where(responder_id: user.id))
  end

  def self.memberships(user)
    Membership.where(user_id: user.id)
  end

  def self.notifications(user)
    Notification.where(user_id: user.id).
      or(Notification.where(actor_id: user.id))
  end

  def self.identities(user)
    OmniauthIdentity.where(user_id: user.id).
      or(OmniauthIdentity.where(email: user.email))
  end

  def self.organisation_visits(user)
    OrganisationVisits.where(user_id: user.id)
  end

  def self.outcomes(user)
    Outcome.where(author_id: user.id)
  end

  def self.poll_did_not_votes(user)
    PollDidNotVotes.where(user_id: user.id)
  end

  def self.poll_unsubscriptions(user)
    PollUnsubscriptions.where(user_id: user.id)
  end

  def self.polls(user)
    Poll.where(author_id: user.id)
  end

  def self.reactions(user)
    Reaction.where(user_id: user.id)
  end

  def self.stances(user)
    Stances.where(participant_id: user.id)
  end

  def self.deactivation_responses(user)
    DeactivationResponse.where(user_id: user.id)
  end

  def self.users(user)
    User.where(id: user.id)
  end

  def self.versions(user)
    Version.where(whodunnit: user.id)
  end
end
