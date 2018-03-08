class Full::UserSerializer < UserSerializer
  attributes :email, :email_when_proposal_closing_soon, :email_missed_yesterday, :email_announcements,
             :email_when_mentioned, :email_on_participation, :selected_locale, :locale,
             :default_membership_volume, :experiences, :is_coordinator, :is_admin,
             :intercom_hash, :pending_identity, :flash

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

  def pending_identity
    from_scope :pending_identity
  end

  def flash
    from_scope :flash
  end

  def is_coordinator
    object.adminable_group_ids.any?
  end

  def intercom_hash
    OpenSSL::HMAC.hexdigest('sha256', ENV['INTERCOM_APP_SECRET'], object.id.to_s)
  end

  def include_gravatar_md5?
    true
  end

  def include_has_password?
    true
  end

  def include_intercom_hash?
    ENV['INTERCOM_APP_SECRET']
  end

  private

  def from_scope(field)
    Array(Hash(scope)[field])
  end
end
