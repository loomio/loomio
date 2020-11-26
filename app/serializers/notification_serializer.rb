class NotificationSerializer < ApplicationSerializer
  attributes :id, :viewed, :created_at, :url, :kind, :translation_values, :actor_id, :event_id
  has_one :actor, serializer: AuthorSerializer, root: :users
  has_one :event, serializer: Notification::EventSerializer, root: :events

  def kind
    if event.kind == "announcement_created"
      event.custom_fields['kind'] || "group_announced"
    else
      event.kind
    end
  end
end
