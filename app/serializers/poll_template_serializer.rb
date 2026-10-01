class PollTemplateSerializer < ActiveModel::Serializer
  embed :ids, include: true

  has_one :group, serializer: GroupSerializer, root: :groups

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
             :example,
             *PollTemplate::SETTINGS.map(&:to_sym)
end
