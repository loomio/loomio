class Restricted::UserSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :restricted, :username, :email, :email_when_proposal_closing_soon, :email_catch_up, :email_newsletter,
             :email_when_mentioned, :email_on_participation, :default_membership_volume, :unsubscribe_token, :locale, :deactivated_at
  has_many :memberships, serializer: Restricted::MembershipSerializer, root: :memberships

  def restricted
    true
  end
end
