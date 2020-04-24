class Full::UserSerializer < UserSerializer
  attributes :email, :email_when_proposal_closing_soon, :email_catch_up,
             :email_when_mentioned, :email_on_participation, :selected_locale,
             :locale, :default_membership_volume, :experiences,
             :email_newsletter, :is_admin, :memberships_count

  has_many :identities,         serializer: IdentitySerializer, root: :identities

  def identities
    from_scope :identities
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
