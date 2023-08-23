class DiscussionTemplateSerializer < ActiveModel::Serializer
  embed :ids, include: true
  
  has_one :group, serializer: GroupSerializer, root: :groups

  attributes :id,
             :key,
             :group_id,
             :position,
             :author_id,
             :process_name,
             :process_subtitle,
             :process_introduction,
             :process_introduction_format,
             :tags,
             :title,
             :description,
             :description_format,
             :content_locale,
             :created_at,
             :updated_at,
             :discarded_at,
             :max_depth,
             :newest_first,
             :poll_template_keys_or_ids
end
