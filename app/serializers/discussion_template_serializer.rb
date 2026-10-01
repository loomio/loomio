class DiscussionTemplateSerializer < ActiveModel::Serializer
  embed :ids, include: true
  
  has_one :group, serializer: GroupSerializer, root: :groups
  has_many :poll_templates, serializer: PollTemplateSerializer, root: :poll_templates

  attributes :id,
             :key,
             :group_id,
             :position,
             :author_id,
             :created_at,
             :updated_at,
             :hidden_at,
             :hider_id,
             :discarded_at,
             *DiscussionTemplate::SETTINGS.map(&:to_sym)
end
