class NotificationSerializer < ApplicationSerializer
  attributes :id, :viewed, :created_at, :url, :kind, :translation_values, :actor_id, :event_id
  has_one :actor, serializer: AuthorSerializer, root: :users

  def kind
    if object.kind == "announcement_created"
      object.event.custom_fields['kind'] || "group_announced"
    else
      object.kind
    end
  end
end
