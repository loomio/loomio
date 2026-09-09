module Ability::UnavailableGroup
  def initialize(user)
    super(user)

    # Register these denials after all ordinary grants. Discard or an inactive
    # subscription suspends content access and activity without removing the
    # roles needed to restore, permanently delete, or clean up personal records.
    cannot :manage, [::Discussion, ::Comment, ::Poll, ::Outcome, ::Topic,
                     ::TopicItem, ::PollTemplate, ::DiscussionTemplate, ::Tag] do |record|
      unavailable_group?(record.group)
    end

    cannot [:update, :publish, :email_members, :view_pending_invitations, :members_autocomplete,
            :show_chatbots, :move_discussions_to, :add_guests, :add_members,
            :invite_people, :announce, :manage_membership_requests, :notify,
            :add_subgroup], ::Group do |group|
      unavailable_group?(group)
    end

    # Group admins are warned to export before deletion is scheduled. Once a
    # group is discarded, restoring it is the only way to regain export access.
    cannot :export, ::Group do |group|
      group.discarded?
    end

    cannot :create, ::Group do |group|
      unavailable_group?(group) || unavailable_group?(group.parent)
    end

    cannot [:make_admin, :make_delegate, :resend], ::Membership do |membership|
      unavailable_group?(membership.group)
    end
    cannot :update, ::Membership do |membership|
      unavailable_group?(membership.group) && membership.user_id != user.id
    end

    cannot [:show, :approve], ::MembershipRequest do |request|
      unavailable_group?(request.group)
    end

    cannot [:make_admin, :resend, :redeem], ::TopicReader do |reader|
      unavailable_group?(reader.topic.group)
    end

    cannot [:redeem, :resend, :redact, :unredact], ::Stance do |stance|
      unavailable_group?(stance.poll.group)
    end

    cannot [:create, :update, :test], ::Chatbot do |chatbot|
      unavailable_group?(chatbot.group)
    end
  end

  private

  def unavailable_group?(group)
    return false if group.nil?

    !group.available?
  end
end
