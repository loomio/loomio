class CurrentUserSerializer < UserSerializer
  attributes :email, :email_when_proposal_closing_soon, :email_missed_yesterday,
             :email_when_mentioned, :email_on_participation, :selected_locale, :locale,
             :default_membership_volume, :experiences, :is_coordinator, :belongs_to_paying_group

  has_many :memberships

  def is_coordinator
    object.is_group_admin?
  end

  def include_gravatar_md5?
    true
  end
end
