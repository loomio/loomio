module Ability::ArchivedGroup
  def initialize(user)
    super(user)

    # Register these denials after all ordinary grants. Archival suspends content
    # access and activity without removing the roles needed to restore, export,
    # delete the group, revoke access, or clean up personal records.
    cannot :manage, [::Discussion, ::Comment, ::Poll, ::Outcome, ::Topic,
                     ::TopicItem, ::PollTemplate, ::DiscussionTemplate, ::Tag] do |record|
      archived_group?(record.group)
    end

    cannot [:update, :email_members, :view_pending_invitations, :members_autocomplete,
            :show_chatbots, :move_discussions_to, :add_guests, :add_members,
            :invite_people, :announce, :manage_membership_requests, :notify,
            :add_subgroup, :move, :merge], ::Group do |group|
      archived_group?(group)
    end

    cannot :create, ::Group do |group|
      archived_group?(group) || archived_group?(group.parent)
    end

    cannot [:make_admin, :make_delegate, :resend], ::Membership do |membership|
      archived_group?(membership.group)
    end
    cannot :update, ::Membership do |membership|
      archived_group?(membership.group) && membership.user_id != user.id
    end

    cannot [:show, :approve], ::MembershipRequest do |request|
      archived_group?(request.group)
    end

    cannot [:make_admin, :resend, :redeem], ::TopicReader do |reader|
      archived_group?(reader.topic.group)
    end

    cannot [:redeem, :resend, :redact, :unredact], ::Stance do |stance|
      archived_group?(stance.poll.group)
    end

    cannot [:create, :update, :test], ::Chatbot do |chatbot|
      archived_group?(chatbot.group)
    end
  end

  private

  def archived_group?(group)
    group.present? && group.archived_at.present?
  end
end
