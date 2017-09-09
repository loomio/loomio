class Events::DiscussionSerializer < Events::BaseSerializer
  has_one :source_group, serializer: Simple::GroupSerializer, root: :groups
  has_one :eventable, serializer: Full::DiscussionSerializer, polymorphic: true, root: :discussions
  has_one :author_membership, serializer: Simple::MembershipSerializer, root: :memberships

  def author_membership
    object.eventable.guest_group.memberships.find_by(user: object.user)
  end

  def source_group
    Group.find(object.custom_fields['source_group_id'])
  end

  def include_source_group?
    object.custom_fields['source_group_id'].present?
  end
end
