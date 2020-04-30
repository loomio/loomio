class NotificationSerializer < ApplicationSerializer
  attributes :id, :viewed, :created_at, :url, :kind, :translation_values, :actor_id, :event_id

  def kind
    if object.kind == "announcement_created"
      object.event.custom_fields['kind'] || "group_announced"
    else
      object.kind
    end
  end

  has_one :actor, serializer: AuthorSerializer, root: :users

  def actor
    if object.kind == 'stance_created'
      object.eventable.participant_for_client
    else
      object.actor
    end
  end
end
