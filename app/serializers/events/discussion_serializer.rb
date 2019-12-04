class Events::DiscussionSerializer < Events::BaseSerializer
  has_one :source_group, serializer: GroupSerializer, root: :groups

  def source_group
    Group.find(object.custom_fields['source_group_id'])
  end

  def include_source_group?
    object.custom_fields['source_group_id'].present?
  end
end
