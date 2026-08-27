class Restricted::UserSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :restricted, :username, :email, :email_when_proposal_closing_soon, :email_catch_up_day, :email_newsletter,
             :email_when_mentioned, :email_on_participation, :default_membership_volume_email,
             :default_membership_volume_push, :locale, :deactivated_at
  has_many :memberships, serializer: Restricted::MembershipSerializer, root: :memberships

  def restricted
    true
  end

  def include_default_membership_volume_email?
    scope && object.id == scope[:current_user_id]
  end

  alias_method :include_default_membership_volume_push?, :include_default_membership_volume_email?
end
