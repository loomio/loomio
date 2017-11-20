module HasGuestGroup
  extend ActiveSupport::Concern
  included do
    belongs_to :guest_group, class_name: "GuestGroup"
    has_many :guests, through: :guest_group, source: :members
  end

  def guest_group
    super || create_guest_group.tap { self.save(validate: false) }
  end

  def invite_guest!(name: nil, email:, inviter: self.author)
    self.guest_group.invitations.find_or_create_by(
      recipient_email: email,
      intent: :"join_#{self.class.to_s.downcase}"
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
