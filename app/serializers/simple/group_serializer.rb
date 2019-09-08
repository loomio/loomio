class Simple::GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :handle,
             :name,
             :full_name,
             :type,
             :created_at,
             :creator_id,
             :is_visible_to_public,
             :memberships_count,
             :pending_memberships_count,
             :membership_granted_upon

  has_one :parent, serializer: GroupSerializer, root: :groups
  has_one :current_user_membership, serializer: MembershipSerializer, root: :memberships

  private

  def current_user_membership
    @current_user_membership ||= object.membership_for(scope[:current_user])
  end

  def include_current_user_membership?
    scope && scope[:current_user]
  end
end
