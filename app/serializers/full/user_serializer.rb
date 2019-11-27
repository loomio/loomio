class Full::UserSerializer < UserSerializer
  attributes :email, :email_when_proposal_closing_soon, :email_catch_up,
             :email_when_mentioned, :email_on_participation, :selected_locale,
             :locale, :default_membership_volume, :experiences, :is_coordinator,
             :email_newsletter, :is_admin, :memberships_count

  has_many :formal_memberships, serializer: MembershipSerializer, root: :memberships
  has_many :guest_memberships,  serializer: Simple::MembershipSerializer, root: :memberships
  has_many :notifications,      serializer: NotificationSerializer, root: :notifications
  has_many :identities,         serializer: IdentitySerializer, root: :identities

  def guest_memberships
    from_scope :guest_memberships
  end

  def formal_memberships
    from_scope :formal_memberships
  end

  def notifications
    from_scope :notifications
  end

  def identities
    from_scope :identities
  end

  def is_coordinator
    object.adminable_group_ids.any?
  end

  def include_email?
    true
  end

  def include_email_hash?
    true
  end

  def include_has_password?
    true
  end

  private

  def from_scope(field)
    Array(Hash(scope)[field])
  end
end
