module Ability::GroupState
  def initialize(user)
    super(user)

    # Discarded groups are treated as deleted. Disabled groups remain readable,
    # while changes and new activity are suspended until they are enabled again.
    cannot :manage, [ ::Discussion, ::Comment, ::Poll, ::Outcome, ::Reaction, ::Topic,
                      ::TopicItem, ::PollTemplate, ::DiscussionTemplate, ::Tag ] do |record|
      discarded_group?(record.group)
    end

    cannot [ :create, :update, :update_version, :destroy, :discard, :undiscard,
             :announce, :add_members, :add_guests, :vote_in, :remind, :add_voters,
             :close, :reopen, :pin, :unpin, :move, :move_comments, :update_tags ],
           [ ::Discussion, ::Comment, ::Poll, ::Outcome, ::Reaction, ::Topic, ::TopicItem,
             ::PollTemplate, ::DiscussionTemplate, ::Tag ] do |record|
      disabled_group?(record.group)
    end

    cannot [ :update, :publish, :subscribe_to, :join, :email_members, :view_pending_invitations, :members_autocomplete,
             :show_chatbots, :move_discussions_to, :add_guests, :add_members,
             :invite_people, :announce, :manage_membership_requests, :notify,
             :add_subgroup ], ::Group do |group|
      group_disabled_or_discarded?(group)
    end

    # Group admins are warned to export before deletion is scheduled. Once a
    # group is discarded, restoring it is the only way to regain export access.
    cannot :export, ::Group do |group|
      group.discarded?
    end

    cannot [ :move, :merge ], ::Group do |group|
      group.discarded?
    end

    cannot :create, ::Group do |group|
      group_disabled_or_discarded?(group) || group_disabled_or_discarded?(group.parent)
    end

    cannot [ :make_admin, :make_delegate, :resend ], ::Membership do |membership|
      group_disabled_or_discarded?(membership.group)
    end
    cannot :update, ::Membership do |membership|
      group_disabled_or_discarded?(membership.group) && membership.user_id != user.id
    end

    cannot [ :show, :create, :cancel, :approve, :ignore ], ::MembershipRequest do |request|
      group_disabled_or_discarded?(request.group)
    end

    cannot [ :make_admin, :resend, :redeem ], ::TopicReader do |reader|
      group_disabled_or_discarded?(reader.topic.group)
    end

    cannot [ :redeem, :resend, :redact, :unredact ], ::Stance do |stance|
      group_disabled_or_discarded?(stance.poll.group)
    end

    cannot [ :create, :update, :test ], ::Chatbot do |chatbot|
      group_disabled_or_discarded?(chatbot.group)
    end

    cannot :update, ::Task do |task|
      group_disabled_or_discarded?(group_for_record(task.record))
    end

    cannot :destroy, ::Attachment do |attachment|
      group_disabled_or_discarded?(group_for_record(attachment.record))
    end
  end

  private

  def group_disabled_or_discarded?(group)
    return false if group.nil?

    discarded_group?(group) || disabled_group?(group)
  end

  def discarded_group?(group)
    group.present? && group.discarded?
  end

  def disabled_group?(group)
    group.present? && group.kept? && !group.subscription_active? && !@user.is_admin?
  end

  def group_for_record(record)
    record.is_a?(::Group) ? record : record&.group
  end
end
