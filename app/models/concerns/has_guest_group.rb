module HasGuestGroup

  def self.included(base)
    base.belongs_to :guest_group, class_name: "GuestGroup"
    base.has_many :guests, through: :guest_group, source: :members
  end

  def guest_group
    super || create_guest_group.tap { self.save(validate: false) }
  end

  def group
    super || NullFormalGroup.new
  end

  def group_members
    User.joins(:memberships)
        .joins(:groups)
        .where("memberships.group_id": group_id)
        .where("groups.members_can_vote IS TRUE OR memberships.admin IS TRUE")
  end

  def members
    User.distinct.from("(#{[group_members, guests].map(&:to_sql).join(" UNION ")}) as users")
  end

  def invitations
    Invitation.where(group_id: [group_id, guest_group_id].compact)
  end

  def invite_guest!(name: nil, email:, inviter: self.author)
    self.guest_group.invitations.find_or_create_by(
      recipient_email: email,
      intent: :join_poll
    ).update(
      recipient_name: name,
      inviter: inviter
    ).tap { self.guest_group.update_pending_invitations_count }
  end

  def anyone_can_participate
    # TODO not sure what invitation -> voter flow is.
    guest_group.membership_granted_upon_request?
  end

  def anyone_can_participate=(bool)
    guest_group.update(membership_granted_upon: if bool then :request else :invitation end)
  end

end
