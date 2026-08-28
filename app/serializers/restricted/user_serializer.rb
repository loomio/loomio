class Restricted::UserSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :restricted, :username, :email, :email_when_proposal_closing_soon, :email_catch_up_day, :email_newsletter,
             :email_when_mentioned, :volume_email_default,
             :volume_push_default, :locale, :deactivated_at
  has_many :memberships, serializer: Restricted::MembershipSerializer, root: :memberships

  def restricted
    true
  end

  def include_volume_email_default?
    scope && object.id == scope[:current_user_id]
  end

  alias_method :include_volume_push_default?, :include_volume_email_default?
end
