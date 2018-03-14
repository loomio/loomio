module HasGuestGroup
  extend ActiveSupport::Concern
  included do
    belongs_to :guest_group, class_name: "GuestGroup"
    has_many :guests, through: :guest_group, source: :members
    has_many :guest_invitations, through: :guest_group, source: :invitations
    after_save :update_anyone_can_participate, if: :update_anyone_can_participate_value
    attr_accessor :update_anyone_can_participate_value
  end

  def groups
    [group, guest_group].compact
  end

  def guest_group
    super || create_guest_group.tap { self.save(validate: false) }
  end

  def invite_guest!(name: nil, email:, inviter: self.author)
    self.guest_group.invitations.find_or_create_by(
      recipient_email: email,
      intent: invitation_intent
    ).update(
      recipient_name: name,
      inviter: inviter
    ).tap { self.guest_group.update_pending_invitations_count }
  end

  def group_members
    User.joins(:memberships).where("memberships.group_id": group_id)
  end

  def guest_members
    guest_group.members.where.not(id: group.presence&.member_ids)
  end

  def members
    User.distinct.from("(#{[group_members, guests].map(&:to_sql).join(" UNION ")}) as users")
  end

  def invitations
    Invitation.where(group_id: [group_id, guest_group_id].compact)
  end

  def invitation_intent
    :"join_#{self.class.to_s.downcase}"
  end

  def anyone_can_participate
    guest_group.membership_granted_upon_request?
  end

  def anyone_can_participate=(bool)
    value = bool ? :request : :invitation
    if new_record?
      self.update_anyone_can_participate_value = value # delay saving until after record is persisted
    else
      self.update_anyone_can_participate value
    end
  end

  def update_anyone_can_participate(value = update_anyone_can_participate_value)
    guest_group.update(membership_granted_upon: value)
  end

end
