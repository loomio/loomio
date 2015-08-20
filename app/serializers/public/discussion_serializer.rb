class Public::DiscussionSerializer < ActiveModel::Serializer
  attributes :key,
             :group_key,
             :title,
             :description,
             :last_activity_at,
             :created_at,
             :updated_at,
             :items_count,
             :comments_count,
             :private,
             :archived_at,
             :created_at,
             :updated_at

  def group_key
    object.group.key
  end

end
